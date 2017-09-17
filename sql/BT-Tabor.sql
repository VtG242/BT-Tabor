--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.18
-- Dumped by pg_dump version 9.4.0
-- Started on 2017-09-17 20:37:43 CEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 2264 (class 1262 OID 83906)
-- Name: BT-Tabor; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "BT-Tabor" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'cs_CZ.UTF-8' LC_CTYPE = 'cs_CZ.UTF-8';


ALTER DATABASE "BT-Tabor" OWNER TO postgres;

\connect "BT-Tabor"

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 178 (class 3079 OID 12018)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2267 (class 0 OID 0)
-- Dependencies: 178
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 185 (class 1255 OID 105513)
-- Name: getplayermaxstepscr(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION getplayermaxstepscr(pid integer, trid integer, step integer) RETURNS integer
    LANGUAGE sql STABLE
    AS $_$
  select max(gscore) from tscore where pid=$1 AND trid=$2 AND tstep=$3;
$_$;


ALTER FUNCTION public.getplayermaxstepscr(pid integer, trid integer, step integer) OWNER TO postgres;

--
-- TOC entry 192 (class 1255 OID 105514)
-- Name: getplayerpomscr(integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION getplayerpomscr(pid integer, tid integer, step integer, tstart integer) RETURNS bigint
    LANGUAGE sql STABLE
    AS $_$
  SELECT sum(gpomscr) FROM tscore WHERE pid=$1 AND trid=$2 AND tstep=$3 AND tstart=$4;
$_$;


ALTER FUNCTION public.getplayerpomscr(pid integer, tid integer, step integer, tstart integer) OWNER TO postgres;

--
-- TOC entry 2268 (class 0 OID 0)
-- Dependencies: 192
-- Name: FUNCTION getplayerpomscr(pid integer, tid integer, step integer, tstart integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION getplayerpomscr(pid integer, tid integer, step integer, tstart integer) IS 'Funkce vraci soucet pomocneho scrore hrace (pid) v turnaji(tid), stepu(step) a startu/restartu (tstart).';


--
-- TOC entry 193 (class 1255 OID 105515)
-- Name: getplayerroundhc(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION getplayerroundhc(trid integer, pid integer) RETURNS integer
    LANGUAGE sql STABLE
    AS $_$
SELECT hc FROM tpresentation WHERE trid=$1 AND pid=$2
$_$;


ALTER FUNCTION public.getplayerroundhc(trid integer, pid integer) OWNER TO postgres;

--
-- TOC entry 2269 (class 0 OID 0)
-- Dependencies: 193
-- Name: FUNCTION getplayerroundhc(trid integer, pid integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION getplayerroundhc(trid integer, pid integer) IS 'Vraci hc hrace (pid) pro turnajove kolo (trid)';


--
-- TOC entry 194 (class 1255 OID 105516)
-- Name: getplayerscore(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION getplayerscore(pid integer, tid integer, step integer) RETURNS character varying
    LANGUAGE sql STABLE
    AS $_$SELECT (array_to_string(array(SELECT to_char(tscore.gscore, '099') FROM tscore WHERE trid=$2 and tstep=$3 and tcount='Y' and pid=$1 ORDER by oid,tstart), ' '))$_$;


ALTER FUNCTION public.getplayerscore(pid integer, tid integer, step integer) OWNER TO postgres;

--
-- TOC entry 2270 (class 0 OID 0)
-- Dependencies: 194
-- Name: FUNCTION getplayerscore(pid integer, tid integer, step integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION getplayerscore(pid integer, tid integer, step integer) IS 'Funkce vraci soucet zapocitanych her (tcount=Y) pro hrace (pid) v turnaji(tid) a stepu(step).';


--
-- TOC entry 195 (class 1255 OID 105517)
-- Name: getplayerscorecsv(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION getplayerscorecsv(pid integer, tid integer, step integer) RETURNS character varying
    LANGUAGE sql STABLE
    AS $_$SELECT (array_to_string(array(SELECT to_char(tscore.gscore, '099') FROM tscore WHERE trid=$2 and tstep=$3 and tcount='Y' and pid=$1 ORDER by oid,tstart), ';'))$_$;


ALTER FUNCTION public.getplayerscorecsv(pid integer, tid integer, step integer) OWNER TO postgres;

--
-- TOC entry 2271 (class 0 OID 0)
-- Dependencies: 195
-- Name: FUNCTION getplayerscorecsv(pid integer, tid integer, step integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION getplayerscorecsv(pid integer, tid integer, step integer) IS 'Funkce vraci soucet zapocitanych her (tcount=Y) pro hrace (pid) v turnaji(tid) a stepu(step) v cvs formatu.';


--
-- TOC entry 196 (class 1255 OID 105518)
-- Name: getplayerscorecsvr(integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION getplayerscorecsvr(pid integer, tid integer, step integer, tstart integer) RETURNS character varying
    LANGUAGE sql STABLE
    AS $_$SELECT (array_to_string(array(SELECT to_char(tscore.gscore, '099') 
      FROM tscore WHERE trid=$2 AND tstep=$3 AND tstart=$4 AND pid=$1 
      ORDER BY oid), ';'))$_$;


ALTER FUNCTION public.getplayerscorecsvr(pid integer, tid integer, step integer, tstart integer) OWNER TO postgres;

--
-- TOC entry 2272 (class 0 OID 0)
-- Dependencies: 196
-- Name: FUNCTION getplayerscorecsvr(pid integer, tid integer, step integer, tstart integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION getplayerscorecsvr(pid integer, tid integer, step integer, tstart integer) IS 'Funkce vraci soucet her pro hrace (pid) v turnaji(tid) a stepu(step) v cvs formatu.';


--
-- TOC entry 197 (class 1255 OID 105519)
-- Name: getplayerscorer(integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION getplayerscorer(pid integer, tid integer, step integer, tstart integer) RETURNS character varying
    LANGUAGE sql STABLE
    AS $_$
  SELECT (array_to_string(array(SELECT to_char(tscore.gscore, '099') FROM tscore WHERE pid=$1 AND trid=$2 AND tstep=$3 AND tstart=$4 
  ORDER by oid), ' '))
$_$;


ALTER FUNCTION public.getplayerscorer(pid integer, tid integer, step integer, tstart integer) OWNER TO postgres;

--
-- TOC entry 2273 (class 0 OID 0)
-- Dependencies: 197
-- Name: FUNCTION getplayerscorer(pid integer, tid integer, step integer, tstart integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION getplayerscorer(pid integer, tid integer, step integer, tstart integer) IS 'Funkce vraci soucet her odehranych hracem (pid) v turnaji(tid), stepu(step) a startu/restartu (tstart).';


--
-- TOC entry 198 (class 1255 OID 105520)
-- Name: getplayerseasonavg(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION getplayerseasonavg(syear integer, pid integer) RETURNS numeric
    LANGUAGE sql STABLE
    AS $_$
  SELECT
  round (avg(gscore),2)
  FROM tscore,tround,tdesc 
  WHERE tscore.trid = tround.trid
  AND tdesc.tid=tround.tid 
  AND (tdesc.ttype='B' OR tdesc.ttype='A')
  AND EXTRACT(YEAR FROM tround.tdate)=$1
  AND tround.tend='Y'
  AND tscore.pid=$2
$_$;


ALTER FUNCTION public.getplayerseasonavg(syear integer, pid integer) OWNER TO postgres;

--
-- TOC entry 2274 (class 0 OID 0)
-- Dependencies: 198
-- Name: FUNCTION getplayerseasonavg(syear integer, pid integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION getplayerseasonavg(syear integer, pid integer) IS 'Vraci prumer hrace (pid) pro zadany rok (syear)';


--
-- TOC entry 199 (class 1255 OID 105521)
-- Name: getplayerseasonhc(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION getplayerseasonhc(syear integer, pid integer) RETURNS numeric
    LANGUAGE sql STABLE
    AS $_$
  SELECT
  round ((160-avg(gscore))/3,0)
  FROM tscore,tround,tdesc 
  WHERE tscore.trid = tround.trid
  AND tdesc.tid=tround.tid 
  AND (tdesc.ttype='B' OR tdesc.ttype='A')
  AND EXTRACT(YEAR FROM tround.tdate)=$1
  AND tround.tend='Y'
  AND tscore.pid=$2
$_$;


ALTER FUNCTION public.getplayerseasonhc(syear integer, pid integer) OWNER TO postgres;

--
-- TOC entry 2275 (class 0 OID 0)
-- Dependencies: 199
-- Name: FUNCTION getplayerseasonhc(syear integer, pid integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION getplayerseasonhc(syear integer, pid integer) IS 'Vraci hc hrace (pid) pro zadany rok (syear) - pozor na zaporne hodnoty!';


--
-- TOC entry 200 (class 1255 OID 105522)
-- Name: getplayersum(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION getplayersum(pid integer, tid integer, step integer) RETURNS bigint
    LANGUAGE sql STABLE
    AS $_$ SELECT SUM(gscore) FROM tscore WHERE pid=$1 AND trid=$2 AND tstep=$3 and tcount='Y' $_$;


ALTER FUNCTION public.getplayersum(pid integer, tid integer, step integer) OWNER TO postgres;

--
-- TOC entry 201 (class 1255 OID 105523)
-- Name: getplayersumr(integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION getplayersumr(pid integer, tid integer, step integer, tstart integer) RETURNS bigint
    LANGUAGE sql STABLE
    AS $_$ SELECT SUM(gscore) FROM tscore WHERE pid=$1 AND trid=$2 AND tstep=$3 AND tstart=$4 $_$;


ALTER FUNCTION public.getplayersumr(pid integer, tid integer, step integer, tstart integer) OWNER TO postgres;

--
-- TOC entry 2276 (class 0 OID 0)
-- Dependencies: 201
-- Name: FUNCTION getplayersumr(pid integer, tid integer, step integer, tstart integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION getplayersumr(pid integer, tid integer, step integer, tstart integer) IS 'Funkce vraci celkovy pocet bodu z her v urcitem stepu a startu';


--
-- TOC entry 202 (class 1255 OID 105524)
-- Name: getplayersumtotal(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION getplayersumtotal(pid integer, tid integer, step integer) RETURNS bigint
    LANGUAGE sql STABLE
    AS $_$
  SELECT SUM(gscore)+SUM(hc) FROM tscore WHERE pid=$1 AND trid=$2 AND tstep=$3 AND tcount='Y'
  $_$;


ALTER FUNCTION public.getplayersumtotal(pid integer, tid integer, step integer) OWNER TO postgres;

--
-- TOC entry 2277 (class 0 OID 0)
-- Dependencies: 202
-- Name: FUNCTION getplayersumtotal(pid integer, tid integer, step integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION getplayersumtotal(pid integer, tid integer, step integer) IS 'Funkce vraci celkovy pocet bodu ze zapoctenych her v urcitem stepu vcetne HC';


--
-- TOC entry 203 (class 1255 OID 105525)
-- Name: getplayersumtotalr(integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION getplayersumtotalr(pid integer, tid integer, step integer, tstart integer) RETURNS bigint
    LANGUAGE sql STABLE
    AS $_$ SELECT SUM(gscore)+SUM(hc) FROM tscore WHERE pid=$1 AND trid=$2 AND tstep=$3 AND tstart=$4 $_$;


ALTER FUNCTION public.getplayersumtotalr(pid integer, tid integer, step integer, tstart integer) OWNER TO postgres;

--
-- TOC entry 2278 (class 0 OID 0)
-- Dependencies: 203
-- Name: FUNCTION getplayersumtotalr(pid integer, tid integer, step integer, tstart integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION getplayersumtotalr(pid integer, tid integer, step integer, tstart integer) IS 'Funkce vraci celkovy pocet bodu z her v urcitem stepu a startu vcetne HC';


--
-- TOC entry 204 (class 1255 OID 105526)
-- Name: getplayertotalavg(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION getplayertotalavg(pid integer, tid integer) RETURNS numeric
    LANGUAGE sql STABLE
    AS $_$
  SELECT round ((SELECT AVG(gscore) FROM tscore WHERE pid=$1 AND trid=$2 and tcount='Y'),2)
$_$;


ALTER FUNCTION public.getplayertotalavg(pid integer, tid integer) OWNER TO postgres;

--
-- TOC entry 205 (class 1255 OID 105527)
-- Name: getplayertotalavgr(integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION getplayertotalavgr(pid integer, tid integer, step integer, tstart integer) RETURNS numeric
    LANGUAGE sql STABLE
    AS $_$
  SELECT round ((SELECT AVG(gscore) FROM tscore WHERE pid=$1 AND trid=$2 AND tstep=$3 AND tstart=$4),2)
$_$;


ALTER FUNCTION public.getplayertotalavgr(pid integer, tid integer, step integer, tstart integer) OWNER TO postgres;

--
-- TOC entry 206 (class 1255 OID 105528)
-- Name: getplayertotalsum(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION getplayertotalsum(pid integer, tid integer) RETURNS bigint
    LANGUAGE sql STABLE
    AS $_$
  SELECT SUM(gscore) FROM tscore WHERE pid=$1 AND trid=$2 AND tcount='Y'
$_$;


ALTER FUNCTION public.getplayertotalsum(pid integer, tid integer) OWNER TO postgres;

--
-- TOC entry 207 (class 1255 OID 105529)
-- Name: playersumhc(integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION playersumhc(pid integer, tid integer, step integer, tstart integer) RETURNS bigint
    LANGUAGE sql STABLE
    AS $_$SELECT SUM(hc) FROM tscore WHERE pid=$1 AND trid=$2 AND tstep=$3 AND tstart=$4$_$;


ALTER FUNCTION public.playersumhc(pid integer, tid integer, step integer, tstart integer) OWNER TO postgres;

--
-- TOC entry 2279 (class 0 OID 0)
-- Dependencies: 207
-- Name: FUNCTION playersumhc(pid integer, tid integer, step integer, tstart integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION playersumhc(pid integer, tid integer, step integer, tstart integer) IS 'Funkce vraci celkovou sumu HC v urcitem stepu a startu';


--
-- TOC entry 170 (class 1259 OID 105530)
-- Name: pid_sq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE pid_sq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pid_sq OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 171 (class 1259 OID 105532)
-- Name: player; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE player (
    pid integer DEFAULT nextval('pid_sq'::regclass) NOT NULL,
    pname character varying(20) NOT NULL,
    psurname character varying(40) NOT NULL,
    pgender character(1) NOT NULL,
    CONSTRAINT pgender_chk CHECK (((pgender = 'M'::bpchar) OR (pgender = 'F'::bpchar)))
);


ALTER TABLE player OWNER TO postgres;

--
-- TOC entry 172 (class 1259 OID 105537)
-- Name: tid_sq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE tid_sq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tid_sq OWNER TO postgres;

--
-- TOC entry 173 (class 1259 OID 105539)
-- Name: tdesc; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE tdesc (
    tid integer DEFAULT nextval('tid_sq'::regclass) NOT NULL,
    tname character varying(100) NOT NULL,
    ttype character(1),
    CONSTRAINT ttype_chk CHECK ((((ttype = 'A'::bpchar) OR (ttype = 'B'::bpchar)) OR (ttype = 'C'::bpchar)))
);


ALTER TABLE tdesc OWNER TO postgres;

SET default_with_oids = true;

--
-- TOC entry 174 (class 1259 OID 105544)
-- Name: tpresentation; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE tpresentation (
    trid integer NOT NULL,
    pid integer NOT NULL,
    hc integer DEFAULT 0,
    body integer DEFAULT 0,
    bc character(1) DEFAULT 'Y'::bpchar NOT NULL
);


ALTER TABLE tpresentation OWNER TO postgres;

--
-- TOC entry 175 (class 1259 OID 105550)
-- Name: trid_sq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE trid_sq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE trid_sq OWNER TO postgres;

SET default_with_oids = false;

--
-- TOC entry 176 (class 1259 OID 105552)
-- Name: tround; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE tround (
    trid integer DEFAULT nextval('trid_sq'::regclass) NOT NULL,
    tid integer NOT NULL,
    tdate date NOT NULL,
    tend character(1) DEFAULT 'N'::bpchar NOT NULL,
    article text,
    CONSTRAINT tend_chk CHECK (((tend = 'Y'::bpchar) OR (tend = 'N'::bpchar)))
);


ALTER TABLE tround OWNER TO postgres;

SET default_with_oids = true;

--
-- TOC entry 177 (class 1259 OID 105561)
-- Name: tscore; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE tscore (
    trid integer NOT NULL,
    pid integer NOT NULL,
    tstep integer NOT NULL,
    tstart integer NOT NULL,
    hc integer DEFAULT 0,
    gscore integer NOT NULL,
    tround integer NOT NULL,
    gpomscr integer DEFAULT 0,
    tcount character(1) DEFAULT 'Y'::bpchar NOT NULL,
    CONSTRAINT gscore_chk CHECK (((gscore >= 0) AND (gscore <= 300))),
    CONSTRAINT tcount_chk CHECK (((tcount = 'Y'::bpchar) OR (tcount = 'N'::bpchar)))
);


ALTER TABLE tscore OWNER TO postgres;

--
-- TOC entry 2143 (class 2606 OID 111018)
-- Name: pid_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY player
    ADD CONSTRAINT pid_pk PRIMARY KEY (pid);


--
-- TOC entry 2145 (class 2606 OID 111020)
-- Name: tid_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tdesc
    ADD CONSTRAINT tid_pk PRIMARY KEY (tid);


--
-- TOC entry 2147 (class 2606 OID 111022)
-- Name: trid_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tround
    ADD CONSTRAINT trid_pk PRIMARY KEY (trid);


--
-- TOC entry 2151 (class 2606 OID 111023)
-- Name: pid_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tscore
    ADD CONSTRAINT pid_fk FOREIGN KEY (pid) REFERENCES player(pid);


--
-- TOC entry 2148 (class 2606 OID 111028)
-- Name: pid_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tpresentation
    ADD CONSTRAINT pid_fk FOREIGN KEY (pid) REFERENCES player(pid);


--
-- TOC entry 2150 (class 2606 OID 111033)
-- Name: tid_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tround
    ADD CONSTRAINT tid_fk FOREIGN KEY (tid) REFERENCES tdesc(tid);


--
-- TOC entry 2152 (class 2606 OID 111038)
-- Name: trid_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tscore
    ADD CONSTRAINT trid_fk FOREIGN KEY (trid) REFERENCES tround(trid);


--
-- TOC entry 2149 (class 2606 OID 111043)
-- Name: trid_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tpresentation
    ADD CONSTRAINT trid_fk FOREIGN KEY (trid) REFERENCES tround(trid);


--
-- TOC entry 2266 (class 0 OID 0)
-- Dependencies: 6
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2017-09-17 20:37:44 CEST

--
-- PostgreSQL database dump complete
--

