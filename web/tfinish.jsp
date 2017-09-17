<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="VtGUtils.*"%>
<%@page import="java.sql.*"%>
<%!    DbPool dbPool = null;

    public void init() {
        dbPool = new DbPool("java:comp/env/jdbc/PGpoolBT");
    }
%>
<%
            request.getSession(true);
            session.setMaxInactiveInterval(-1);

            Connection conn = dbPool.getDBConn();
            PreparedStatement pstmt = null;
            ResultSet resultSet = null;
            String sqlQuery = "";
            int p = 0;
            int body = 0;

            if (session.getAttribute("tType").equals("C")) {

                sqlQuery = "SELECT DISTINCT "
                        + "tscore.tstep as tstep,"
                        + "tscore.tround as tround,"
                        + "tscore.tstart as tstart,"
                        + "player.pid as pid,"
                        + "player.psurname as psurname,"
                        + "player.pname as pname,"
                        + "getplayerscore(tscore.pid,tscore.trid,1) as qualif_score,"
                        + "getplayersum(tscore.pid,tscore.trid,1) as qualif_total,"
                        + "getplayersumtotal(tscore.pid,tscore.trid,1) as qualif_total_hc,"
                        + "getplayerscore(tscore.pid,tscore.trid,2) as final_score,"
                        + "getplayersum(tscore.pid,tscore.trid,2) as final_total,"
                        + "getplayertotalavg(tscore.pid,tscore.trid) as total_avg,"
                        + "getplayersumtotal(tscore.pid,tscore.trid,2) as final_total_hc,"
                        + "getplayermaxstepscr(tscore.pid,tscore.trid,1) as kmax,"
                        + "getplayermaxstepscr(tscore.pid,tscore.trid,2) as fmax,"
                        + "getplayerpomscr(tscore.pid,tscore.trid,1,tscore.tstart) as kpomscr,"
                        + "getplayerpomscr(tscore.pid,tscore.trid,2,tscore.tstart) as fpomscr,"
                        + "tscore.tcount as tcount, "
                        + "tpresentation.hc as hc "
                        + "FROM tscore,player,tpresentation "
                        + "WHERE tscore.trid=? AND tscore.tstep=1 AND tscore.tcount='Y' AND player.pid=tscore.pid AND player.pid=tpresentation.pid "
                        + "GROUP BY tscore.tstep,tscore.trid, tscore.pid, tscore.tround, tscore.tstart, tscore.tcount, player.pid, player.psurname, player.pname, tpresentation.hc "
                        + "ORDER BY tstep DESC, final_total_hc DESC NULLS LAST, final_total DESC NULLS LAST, fmax DESC, fpomscr DESC, qualif_total_hc DESC, qualif_total DESC, kmax DESC, kpomscr DESC";

            } else if (session.getAttribute("tType").equals("B")) {

                sqlQuery = "SELECT DISTINCT "
                        + "tscore.tstep as tstep,"
                        + "tscore.tround as tround,"
                        + "tscore.tstart as tstart,"
                        + "player.pid as pid,"
                        + "player.psurname as psurname,"
                        + "player.pname as pname,"
                        + "tpresentation.hc as hc,"
                        + "getplayerscore(tscore.pid,tscore.trid,1) as qualif_score,"
                        + "getplayersum(tscore.pid,tscore.trid,1) as qualif_total,"
                        + "getplayersumtotal(tscore.pid,tscore.trid,1) as qualif_total_hc,"
                        + "getplayertotalavgr(tscore.pid,tscore.trid,1,tscore.tstart) as qualif_avg,"
                        + "getplayerscore(tscore.pid,tscore.trid,2) as final_score,"
                        + "getplayersum(tscore.pid,tscore.trid,2) as final_total,"
                        + "getplayersumtotal(tscore.pid,tscore.trid,2) as final_total_hc,"
                        + "getplayertotalavg(tscore.pid,tscore.trid) as total_avg,"
                        + "(getplayertotalavgr(tscore.pid,tscore.trid,1,tscore.tstart) + getplayersum(tscore.pid,tscore.trid,2)) as tournament_total,"
                        + "(getplayertotalavgr(tscore.pid,tscore.trid,1,tscore.tstart) + getplayersumtotal(tscore.pid,tscore.trid,2)) as tournament_total_hc,"
                        + "getplayermaxstepscr(tscore.pid,tscore.trid,1) as kmax,"
                        + "getplayermaxstepscr(tscore.pid,tscore.trid,2) as fmax,"
                        + "getplayerpomscr(tscore.pid,tscore.trid,1,tscore.tstart) as kpomscr,"
                        + "getplayerpomscr(tscore.pid,tscore.trid,2,tscore.tstart) as fpomscr,"
                        + "tscore.tcount as tcount "
                        + "FROM tscore,player,tpresentation "
                        + "WHERE tscore.trid=? AND tscore.tstep=1 AND tscore.tcount='Y' AND player.pid=tscore.pid AND player.pid=tpresentation.pid "
                        + "GROUP BY tscore.tstep,tscore.trid, tscore.pid, tscore.tround, tscore.tstart, tscore.tcount, player.pid, player.psurname, player.pname, tpresentation.hc "
                        + "ORDER BY tstep DESC, tournament_total_hc DESC NULLS LAST, tournament_total DESC NULLS LAST, fmax DESC, fpomscr DESC, qualif_total_hc DESC, qualif_total DESC, kmax DESC, kpomscr DESC";
            } else {

                sqlQuery = "SELECT "
                        + "tscore.tstep as tstep,"
                        + "tscore.tround as tround,"
                        + "tscore.tstart as tstart,"
                        + "player.pid as pid,"
                        + "player.psurname as psurname,"
                        + "player.pname as pname,"
                        + "getplayerroundhc(tscore.trid,player.pid) AS hc,"
                        + "getplayerscore(tscore.pid,tscore.trid,1) as qualif_score,"
                        + "getplayersum(tscore.pid,tscore.trid,1) as qualif_total,"
                        + "getplayersumtotal(tscore.pid,tscore.trid,1) as qualif_total_hc," //potrebujeme pro trideni lidi nepostupujicich do finale
                        + "getplayerscore(tscore.pid,tscore.trid,2) as final_score,"
                        + "getplayersum(tscore.pid,tscore.trid,2) as final_total,"
                        + "getplayertotalavg(tscore.pid,tscore.trid) as total_avg,"
                        + "(getplayersum(tscore.pid,tscore.trid,1) + getplayersum(tscore.pid,tscore.trid,2)) AS total,"
                        + "(getplayersumtotal(tscore.pid,tscore.trid,1) + getplayersumtotal(tscore.pid,tscore.trid,2)) AS total_hc,"
                        + "getplayermaxstepscr(tscore.pid,tscore.trid,1) as kmax,"
                        + "getplayermaxstepscr(tscore.pid,tscore.trid,2) as fmax,"
                        + "getplayerpomscr(tscore.pid,tscore.trid,1,tscore.tstart) as kpomscr,"
                        + "getplayerpomscr(tscore.pid,tscore.trid,2,tscore.tstart) as fpomscr,"
                        + "tscore.tcount as tcount "
                        + "FROM tscore,player "
                        + "WHERE tscore.trid=? AND tscore.tstep=1 AND tscore.tcount='Y' AND player.pid=tscore.pid "
                        + "GROUP BY tscore.tstep,tscore.trid,tscore.pid,tscore.tround,tscore.tstart,tscore.tcount,player.pid,player.psurname,player.pname "
                        + "ORDER BY tstep DESC,total_hc DESC NULLS LAST,total DESC NULLS LAST,fmax DESC,fpomscr DESC,qualif_total_hc DESC,qualif_total DESC,kmax DESC,kpomscr DESC";
            }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <link rel=StyleSheet href="css/tables.css" type="text/css"/>
        <title>BT - Ukončení turnaje</title>
    </head>
    <body>

        <table>
            <caption>Ukončení turnaje </caption>
            <thead><tr><th>&nbsp;</th><th>Hráč</th><th>body</th></tr></thead>
            <tbody>

                <%
                            try {
                                //pocet bodu
                                pstmt = conn.prepareStatement("SELECT count(*) FROM (SELECT pid FROM tscore WHERE trid=? AND tcount='Y' GROUP BY pid) AS body");
                                pstmt.setInt(1, (Integer) session.getAttribute("trID"));
                                resultSet = pstmt.executeQuery();
                                resultSet.next();
                                body = resultSet.getInt(1);

                                pstmt = conn.prepareStatement(sqlQuery);
                                pstmt.setInt(1, (Integer) session.getAttribute("trID"));

                                resultSet = pstmt.executeQuery();

                                while (resultSet.next()) {
                                    p += 1;
                                    out.println("<tr><td>" + p + ".</td><td style='text-align: left'>" + resultSet.getString("psurname") + " " + resultSet.getString("pname") + "</td><td>" + body + "</td></tr>");
                                    body -= 1;
                                }

                            } catch (SQLException e) {
                                if (session.getAttribute("s_msg") == null) {
                                    session.setAttribute("s_msg", "Chyba SQL: " + e.getMessage());
                                } else {
                                    session.setAttribute("s_msg", (session.getAttribute("s_msg") + "<br/>Chyba SQL: " + e.getMessage()));
                                }
                            }
                %>
            </tbody>
            <tfoot>
                <form method="post" action="Tfinish">
                    <tr><td colspan="3">
                            <% if ((Boolean) session.getAttribute("Debug")) {
                                            out.println(sqlQuery);
                                        }%>
                            <span style="color: red"><%= session.getAttribute("s_msg") != null ? session.getAttribute("s_msg") + "<br/>" : ""%></span>
                            <%session.removeAttribute("s_msg");%>
                        </td>
                    </tr>
                    <tr><td colspan="3">Ukončit a zapsat body<br/> do celkového pořadí?<br/><input type="submit" value="ANO"/><br/><br/></td></tr>
                </form>
            </tfoot>
        </table>

    </body>
</html>
<%
            if (resultSet != null) {
                resultSet.close();
            }
            if (pstmt != null) {
                pstmt.close();
            }
            if (conn != null) {
                conn.close();
            }
%>
