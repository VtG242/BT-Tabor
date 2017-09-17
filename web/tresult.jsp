<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="VtGUtils.*,java.sql.*"%>
<%!    DbPool dbPool = null;

    public void init() {
        dbPool = new DbPool("java:comp/env/jdbc/PGpoolBT");
    }
%>
<%
            request.getSession(true);
            session.setMaxInactiveInterval(-1);

            //nastaveni stalych promenych do session
            session.setAttribute("backURL", "tresult.jsp?sort=9");

            //inicializace promenych pro trideni
            Connection conn = dbPool.getDBConn();
            PreparedStatement pstmt = null;
            ResultSet resultSet = null;
            String sort = "";
            String sortDesc = "&nbsp;";
            String sqlQuery = "";
            int p = 0;
            //postupne vytvorime dle typu turnaje dbdotaz
            StringBuilder sqlQueryFinal = new StringBuilder("SELECT "
                    + "tscore.tstep as tstep,"
                    + "tscore.tround as tround,"
                    + "player.pid as pid,"
                    + "player.psurname as psurname,"
                    + "player.pname as pname,"
                    + "getplayerroundhc(tscore.trid,player.pid) AS hc,"
                    + "getplayerscore(tscore.pid,tscore.trid,1) as qualif_score,"
                    + "playersumhc(tscore.pid,tscore.trid,1,tscore.tstart) AS qualif_hc,"
                    + "getplayersum(tscore.pid,tscore.trid,1) as qualif_total,"
                    + "getplayersumtotal(tscore.pid,tscore.trid,1) as qualif_total_hc,"
                    + "getplayertotalavgr(tscore.pid,tscore.trid,1,tscore.tstart) as qualif_avg,"
                    + "getplayerscore(tscore.pid,tscore.trid,2) as final_score,"
                    + "playersumhc(tscore.pid,tscore.trid,2,tscore.tstart) AS final_hc,"
                    + "getplayersum(tscore.pid,tscore.trid,2) as final_total,"
                    + "getplayersumtotal(tscore.pid,tscore.trid,2) as final_total_hc,"
                    + "getplayertotalavgr(tscore.pid,tscore.trid,2,tscore.tstart) as final_avg,"
                    + "getplayertotalavg(tscore.pid,tscore.trid) as total_avg,"
                    + "getplayermaxstepscr(tscore.pid,tscore.trid,1) as kmax,"
                    + "getplayermaxstepscr(tscore.pid,tscore.trid,2) as fmax,"
                    + "getplayerpomscr(tscore.pid,tscore.trid,1,tscore.tstart) as kpomscr,"
                    + "getplayerpomscr(tscore.pid,tscore.trid,2,tscore.tstart) as fpomscr,"
                    + "tscore.tcount as tcount, ");

            if (session.getAttribute("tType").equals("C")) {

                sqlQueryFinal.append("getplayersum(tscore.pid,tscore.trid,2) as tournament_total,getplayersumtotal(tscore.pid,tscore.trid,2) as tournament_total_hc ");
                //cisla oznacuji sloupce v zobrazene html tabulce
                switch (Integer.parseInt(request.getParameter("sort"))) {
                    case 11: //final_total
                        sort = "final_total DESC NULLS LAST, fmax DESC, fpomscr DESC, qualif_total DESC, kmax DESC, kpomscr DESC";
                        sortDesc = "Metodika třídění: <img src='img/desc.jpg'/> Finálový součet bez HC <img src='img/desc.jpg'/> Nejvyší nához";
                        break;
                    case 12: //final_total_hc
                        sort = "final_total_hc DESC NULLS LAST, final_total DESC NULLS LAST, fmax DESC, fpomscr DESC, qualif_total_hc DESC, qualif_total DESC, kmax DESC, kpomscr DESC";
                        sortDesc = "Metodika třídění: <img src='img/desc.jpg'/> Finálový součet s HC <img src='img/desc.jpg'/> Finálový součet <img src='img/desc.jpg'/> Nejvyší nához";
                        break;
                    case 13: //final_avg
                        sort = "final_avg DESC NULLS LAST, fmax DESC, fpomscr DESC";
                        sortDesc = "Metodika třídění: <img src='img/desc.jpg'/> Finálový průměr bez HC <img src='img/desc.jpg'/> Nejvyší nához";
                        break;
                    case 14: //final_total_hc
                        sort = "total_avg DESC, fmax DESC, fpomscr DESC";
                        sortDesc = "Metodika třídění: <img src='img/desc.jpg'/> Celkový průměr bez HC <img src='img/desc.jpg'/> Finálový součet <img src='img/desc.jpg'/> Nejvyší nához";
                        break;
                    case 15: //tournament_total_hc
                        sort = "tournament_total_hc DESC NULLS LAST, tournament_total DESC NULLS LAST, fmax DESC, fpomscr DESC, qualif_total_hc DESC, qualif_total DESC, kmax DESC, kpomscr DESC";
                        sortDesc = "Metodika třídění: <img src='img/desc.jpg'/> Finálový součet s HC <img src='img/desc.jpg'/> Finálový součet bez HC <img src='img/desc.jpg'/> Nejvyší nához";
                        break;
                }

            } else if (session.getAttribute("tType").equals("B")) {

                sqlQueryFinal.append("(getplayertotalavgr(tscore.pid,tscore.trid,1,tscore.tstart) + getplayersum(tscore.pid,tscore.trid,2)) as tournament_total,(getplayertotalavgr(tscore.pid,tscore.trid,1,tscore.tstart) + getplayersumtotal(tscore.pid,tscore.trid,2)) as tournament_total_hc ");
                //cisla oznacuji sloupce v zobrazene html tabulce
                switch (Integer.parseInt(request.getParameter("sort"))) {
                    case 11: //final_total
                        sort = "final_total DESC NULLS LAST, fmax DESC, fpomscr DESC, qualif_total DESC, kmax DESC, kpomscr DESC";
                        sortDesc = "Metodika třídění: <img src='img/desc.jpg'/> Finálový součet bez HC <img src='img/desc.jpg'/> Nejvyší nához";
                        break;
                    case 12: //final_total_hc
                        sort = "final_total_hc DESC NULLS LAST, final_total DESC NULLS LAST, fmax DESC, fpomscr DESC, qualif_total_hc DESC, qualif_total DESC, kmax DESC, kpomscr DESC";
                        sortDesc = "Metodika třídění: <img src='img/desc.jpg'/> Finálový součet s HC <img src='img/desc.jpg'/> Finálový součet <img src='img/desc.jpg'/> Nejvyší nához";
                        break;
                    case 13: //final_avg
                        sort = "final_avg DESC NULLS LAST, fmax DESC, fpomscr DESC";
                        sortDesc = "Metodika třídění: <img src='img/desc.jpg'/> Finálový průměr bez HC <img src='img/desc.jpg'/> Nejvyší nához";
                        break;
                    case 14: //final_total_hc
                        sort = "total_avg DESC, fmax DESC, fpomscr DESC";
                        sortDesc = "Metodika třídění: <img src='img/desc.jpg'/> Celkový průměr bez HC <img src='img/desc.jpg'/> Finálový součet <img src='img/desc.jpg'/> Nejvyší nához";
                        break;
                    case 15: //Pocita se soucet finalovych her vcetne HC + prumer z kvalifikace.
                        sort = "tournament_total_hc DESC NULLS LAST, tournament_total DESC NULLS LAST, fmax DESC, fpomscr DESC, qualif_total_hc DESC, qualif_total DESC, kmax DESC, kpomscr DESC";
                        sortDesc = "Metodika třídění: <img src='img/desc.jpg'/> Finálový součet + HC + &empty; z kvalifikace <img src='img/desc.jpg'/> Finálový součet + &empty; z kvalifikace <img src='img/desc.jpg'/> Nejvyší finál. nához";
                        break;
                }

            } else {
                sqlQueryFinal.append("(getplayersum(tscore.pid,tscore.trid,1) + getplayersum(tscore.pid,tscore.trid,2)) AS tournament_total, (getplayersumtotal(tscore.pid,tscore.trid,1) + getplayersumtotal(tscore.pid,tscore.trid,2)) AS tournament_total_hc ");
                //cisla oznacuji sloupce v zobrazene html tabulce
                switch (Integer.parseInt(request.getParameter("sort"))) {
                    case 11: //final_total
                        sort = "final_total DESC NULLS LAST, fmax DESC, fpomscr DESC, qualif_total DESC, kmax DESC, kpomscr DESC";
                        sortDesc = "Metodika třídění: <img src='img/desc.jpg'/> Finálový součet bez HC <img src='img/desc.jpg'/> Nejvyší nához";
                        break;
                    case 12: //final_total_hc
                        sort = "final_total_hc DESC NULLS LAST, final_total DESC NULLS LAST, fmax DESC, fpomscr DESC, qualif_total_hc DESC, qualif_total DESC, kmax DESC, kpomscr DESC";
                        sortDesc = "Metodika třídění: <img src='img/desc.jpg'/> Finálový součet s HC <img src='img/desc.jpg'/> Finálový součet <img src='img/desc.jpg'/> Nejvyší nához";
                        break;
                    case 13: //final_avg
                        sort = "final_avg DESC NULLS LAST, fmax DESC, fpomscr DESC";
                        sortDesc = "Metodika třídění: <img src='img/desc.jpg'/> Finálový průměr bez HC <img src='img/desc.jpg'/> Nejvyší nához";
                        break;
                    case 14: //final_total_hc
                        sort = "total_avg DESC, fmax DESC, fpomscr DESC";
                        sortDesc = "Metodika třídění: <img src='img/desc.jpg'/> Celkový průměr bez HC <img src='img/desc.jpg'/> Finálový součet <img src='img/desc.jpg'/> Nejvyší nához";
                        break;
                    case 15: //Pocita se soucet finalovych her vcetne HC + prumer z kvalifikace.
                        sort = "tournament_total_hc DESC NULLS LAST,tournament_total DESC NULLS LAST,fmax DESC,fpomscr DESC,qualif_total_hc DESC,qualif_total DESC,kmax DESC,kpomscr DESC";
                        sortDesc = "Metodika třídění: <img src='img/desc.jpg'/> Součet her z K + F + HC <img src='img/desc.jpg'/> Součet her z K + F bez HC <img src='img/desc.jpg'/> Nejvyší nához";
                        break;
                }
            }

            sqlQueryFinal.append("FROM tscore,player "
                    + "WHERE tscore.trid=? AND tscore.tstep=1 AND tscore.tcount='Y' AND player.pid=tscore.pid "
                    + "GROUP BY tscore.tstep,tscore.trid, tscore.pid, tscore.tround, tscore.tstart, tscore.tcount, player.pid, player.psurname, player.pname "
                    + "ORDER BY tstep DESC, ");
            sqlQueryFinal.append(sort);
%>
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <link rel=StyleSheet href="css/tables.css" type="text/css"/>
        <title>BT - Bowlingové turnaje - Celkové výsledky</title>
    </head>
    <body>
        <%if (session.getAttribute("tType").equals("C")) {%>
        <table>
            <caption>C E L K O V É &nbsp;&nbsp; V Ý S L E D K Y</caption>
            <thead>
                <tr align="center">
                    <th>&nbsp;</th>
                    <th>hráč</th>
                    <th>H</th>
                    <th>kvalifikace (K)</th>
                    <th>&sum;KH</th>
                    <th>&sum;K</th>
                    <th>&sum;KH+&sum;K</th>
                    <th>&empty;(K)</th>
                    <th>finále (F)</th>
                    <th>&sum;FH</th>
                    <th><a href="tresult.jsp?sort=11" title="Celkový součet bodů z finálových her">&sum;F</a></th>
                    <th><a href="tresult.jsp?sort=12" title="Celkový součet bodů z finálových her + součet handicapů">&sum;F+&sum;FH</a></th>
                    <th><a href="tresult.jsp?sort=13" title="Průměr z finálových her bez HC">&empty;(F)</a></th>
                    <th><a href="tresult.jsp?sort=14" title="Celkový průměr bez HC">&empty;(FK)</a></th>
                    <th><a href="tresult.jsp?sort=15" title="Celkový součet bodů z finálových her + suma finálových HC">F+&sum;FHC</a></th>
                </tr>
            </thead>
            <tbody>
                <%
                    try {
                        pstmt = conn.prepareStatement(sqlQueryFinal.toString());
                        pstmt.setInt(1, (Integer) session.getAttribute("trID"));

                        resultSet = pstmt.executeQuery();

                        while (resultSet.next()) {

                            p += 1;

                            out.print("<tr>"
                                    + "<td>" + (sort.equals("psurname") ? " " : p) + ".&nbsp;</td>"
                                    + "<td style='text-align:left;font-weight:bolder'>" + resultSet.getString("psurname") + " " + resultSet.getString("pname") + "</td>"
                                    + "<td>" + resultSet.getString("hc") + "</td>"
                                    + "<td style='font-size: 95%'>" + resultSet.getString("qualif_score") + "</td>"
                                    + "<td>" + resultSet.getString("qualif_hc") + "</td>"
                                    + "<td>" + resultSet.getString("qualif_total") + "</td>"
                                    + "<td>" + resultSet.getString("qualif_total_hc") + "</td>"
                                    + "<td>" + resultSet.getString("qualif_avg") + "</td>"
                                    + "<td style='font-size: 95%'>" + (resultSet.getString("final_score") == null ? " " : resultSet.getString("final_score")) + "</td>"
                                    + "<td>" + (resultSet.getString("final_hc") == null ? " " : resultSet.getString("final_hc")) + "</td>"
                                    + "<td " + (request.getParameter("sort").equals("11") ? "style='background-color:AliceBlue;font-weight:bold" : "") + "'>" + (resultSet.getString("final_total") == null ? " " : resultSet.getString("final_total")) + "</td>"
                                    + "<td " + (request.getParameter("sort").equals("12") ? "style='background-color:AliceBlue;font-weight:bold" : "") + "'>" + (resultSet.getString("final_total_hc") == null ? " " : resultSet.getString("final_total_hc")) + "</td>"
                                    + "<td " + (request.getParameter("sort").equals("13") ? "style='background-color:AliceBlue;font-weight:bold" : "") + "'>" + (resultSet.getString("final_avg") == null ? " " : resultSet.getString("final_avg")) + "</td>"
                                    + "<td " + (request.getParameter("sort").equals("14") ? "style='background-color:AliceBlue;font-weight:bold" : "") + "'>" + resultSet.getString("total_avg") + "</td>"
                                    + "<td " + (request.getParameter("sort").equals("15") ? "style='background-color:AliceBlue;font-weight:bold" : "") + "'>" + (resultSet.getString("tournament_total_hc") == null ? " " : resultSet.getString("tournament_total_hc")) + "</td>"
                                    + "</tr>");
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
                <tr>
                    <td colspan="16">
                        <% if ((Boolean) session.getAttribute("Debug")) {
                                out.println(sqlQueryFinal.toString() + "<br/>");
                            }%>
                        <span style="color: red"><%= session.getAttribute("s_msg") != null ? session.getAttribute("s_msg") + "<br/>" : ""%></span>
                        <%session.removeAttribute("s_msg");%>
                    </td>
                </tr>
                <tr>
                    <td colspan="16">
                        <%=sortDesc%><br/>
                        Exporty: <a href="CsvExport?type=<%=session.getAttribute("tType")%>">[ csv ]</a> GoodData - <a href="GDExportPlayers?type=<%=session.getAttribute("tType")%>">[ Players ]</a>
                    </td>
                </tr>
            </tfoot>
        </table>
        <%} else if (session.getAttribute("tType").equals("B")) {%>
        <table>
            <caption>C E L K O V É &nbsp;&nbsp; V Ý S L E D K Y - [ <a href="">stručné</a> ]&nbsp;[ <a href="">detailní</a> ]  </caption>
            <thead>
                <tr align="center">
                    <th>&nbsp;</th>
                    <th>hráč</th>
                    <th>H</th>
                    <th>kvalifikace (K)</th>
                    <th>&sum;KH</th>
                    <th>&sum;K</th>
                    <th>&sum;KH+&sum;K</th>
                    <th>&empty;(K)</th>
                    <th>finále (F)</th>
                    <th>&sum;FH</th>
                    <th><a href="tresult.jsp?sort=11" title="Celkový součet bodů z finálových her">&sum;F</a></th>
                    <th><a href="tresult.jsp?sort=12" title="Celkový součet bodů z finálových her + součet handicapů">&sum;F+&sum;FH</a></th>
                    <th><a href="tresult.jsp?sort=13" title="Průměr z finálových her bez HC">&empty;(F)</a></th>
                    <th><a href="tresult.jsp?sort=14" title="Celkový průměr bez HC">&empty;(FK)</a></th>
                    <th><a href="tresult.jsp?sort=15" title="Celkový součet bodů z finálových her + součet finálových HC + průměr z kvalifikace bez HC">&empty;K+&sum;F+&sum;FH</a></th>
                </tr>
            </thead>
            <tbody>
                <%
                    try {
                        pstmt = conn.prepareStatement(sqlQueryFinal.toString());
                        pstmt.setInt(1, (Integer) session.getAttribute("trID"));
                        //pstmt.setString(2,(String)session.getAttribute("tsort"));

                        resultSet = pstmt.executeQuery();

                        while (resultSet.next()) {

                            p += 1;

                            out.print("<tr>"
                                    + "<td>" + (sort.equals("psurname") ? " " : p) + ".&nbsp;</td>"
                                    + "<td style='text-align:left;font-weight:bolder'>" + resultSet.getString("psurname") + " " + resultSet.getString("pname") + "</td>"
                                    + "<td>" + resultSet.getString("hc") + "</td>"
                                    + "<td style='font-size: 95%'>" + resultSet.getString("qualif_score") + "</td>"
                                    + "<td>" + resultSet.getString("qualif_hc") + "</td>"
                                    + "<td>" + resultSet.getString("qualif_total") + "</td>"
                                    + "<td>" + resultSet.getString("qualif_total_hc") + "</td>"
                                    + "<td>" + resultSet.getString("qualif_avg") + "</td>"
                                    + "<td style='font-size: 95%'>" + (resultSet.getString("final_score") == null ? " " : resultSet.getString("final_score")) + "</td>"
                                    + "<td>" + (resultSet.getString("final_hc") == null ? " " : resultSet.getString("final_hc")) + "</td>"
                                    + "<td " + (request.getParameter("sort").equals("11") ? "style='background-color:AliceBlue;font-weight:bold" : "") + "'>" + (resultSet.getString("final_total") == null ? " " : resultSet.getString("final_total")) + "</td>"
                                    + "<td " + (request.getParameter("sort").equals("12") ? "style='background-color:AliceBlue;font-weight:bold" : "") + "'>" + (resultSet.getString("final_total_hc") == null ? " " : resultSet.getString("final_total_hc")) + "</td>"
                                    + "<td " + (request.getParameter("sort").equals("13") ? "style='background-color:AliceBlue;font-weight:bold" : "") + "'>" + (resultSet.getString("final_avg") == null ? " " : resultSet.getString("final_avg")) + "</td>"
                                    + "<td " + (request.getParameter("sort").equals("14") ? "style='background-color:AliceBlue;font-weight:bold" : "") + "'>" + resultSet.getString("total_avg") + "</td>"
                                    + "<td " + (request.getParameter("sort").equals("15") ? "style='background-color:AliceBlue;font-weight:bold" : "") + "'>" + (resultSet.getString("tournament_total_hc") == null ? " " : resultSet.getString("tournament_total_hc")) + "</td>"
                                    + "</tr>");
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
                <tr>
                    <td colspan="16">
                        <% if ((Boolean) session.getAttribute("Debug")) {
                                out.println(sqlQueryFinal.toString() + "<br/>");
                            }%>
                        <span style="color: red"><%= session.getAttribute("s_msg") != null ? session.getAttribute("s_msg") + "<br/>" : ""%></span>
                        <%session.removeAttribute("s_msg");%>
                    </td>
                </tr>
                <tr>
                    <td colspan="16">
                        <%=sortDesc%><br/>
                        Exporty: <a href="CsvExport?type=<%=session.getAttribute("tType")%>">[ ČBA - csv ]</a> GoodData - <a href="GDExportPlayers?type=<%=session.getAttribute("tType")%>">[ Players ]</a> 
                    </td>
                </tr>
            </tfoot>

        </table>
        <%} else {%>
        <table>
            <caption>C E L K O V É &nbsp;&nbsp; V Ý S L E D K Y - (&sum;KF + &sum;HC) [ <a href="">stručné</a> ]&nbsp;[ <a href="">detailní</a> ]</caption>
            <thead>
                <tr align="center">
                    <th>&nbsp;</th>
                    <th>hráč</th>
                    <th>H</th>
                    <th>kvalifikace (K)</th>
                    <th>&sum;KH</th>
                    <th>&sum;K</th>
                    <th>&sum;KH+&sum;K</th>
                    <th>&empty;(K)</th>
                    <th>finále (F)</th>
                    <th>&sum;FH</th>
                    <th><a href="tresult.jsp?sort=11" title="Celkový součet bodů z finálových her">&sum;F</a></th>
                    <th><a href="tresult.jsp?sort=12" title="Celkový součet bodů z finálových her + suma handicapů">&sum;F+&sum;FH</a></th>
                    <th><a href="tresult.jsp?sort=13" title="Průměr z finálových her bez HC">&empty;(F)</a></th>
                    <th><a href="tresult.jsp?sort=14" title="Celkový průměr bez HC">&empty;(FK)</a></th>
                    <th><a href="tresult.jsp?sort=15" title="Celkový součet bodů z kvalifikace a finále + suma handicapů">&sum;KF+&sum;HC</a></th>
                </tr>
            </thead>
            <tbody>
                <%
                    try {
                        pstmt = conn.prepareStatement(sqlQueryFinal.toString());
                        pstmt.setInt(1, (Integer) session.getAttribute("trID"));
                        //pstmt.setString(2,(String)session.getAttribute("tsort"));

                        resultSet = pstmt.executeQuery();

                        while (resultSet.next()) {

                            p += 1;

                            out.print("<tr>"
                                    + "<td>" + (sort.equals("psurname") ? " " : p) + ".&nbsp;</td>"
                                    + "<td style='text-align:left;font-weight:bolder'>" + resultSet.getString("psurname") + " " + resultSet.getString("pname") + "</td>"
                                    + "<td>" + resultSet.getString("hc") + "</td>"
                                    + "<td style='font-size: 95%'>" + resultSet.getString("qualif_score") + "</td>"
                                    + "<td>" + resultSet.getString("qualif_hc") + "</td>"
                                    + "<td>" + resultSet.getString("qualif_total") + "</td>"
                                    + "<td>" + resultSet.getString("qualif_total_hc") + "</td>"
                                    + "<td>" + resultSet.getString("qualif_avg") + "</td>"
                                    + "<td style='font-size: 95%'>" + (resultSet.getString("final_score") == null ? " " : resultSet.getString("final_score")) + "</td>"
                                    + "<td>" + (resultSet.getString("final_hc") == null ? " " : resultSet.getString("final_hc")) + "</td>"
                                    + "<td " + (request.getParameter("sort").equals("11") ? "style='background-color:AliceBlue;font-weight:bold" : "") + "'>" + (resultSet.getString("final_total") == null ? " " : resultSet.getString("final_total")) + "</td>"
                                    + "<td " + (request.getParameter("sort").equals("12") ? "style='background-color:AliceBlue;font-weight:bold" : "") + "'>" + (resultSet.getString("final_total_hc") == null ? " " : resultSet.getString("final_total_hc")) + "</td>"
                                    + "<td " + (request.getParameter("sort").equals("13") ? "style='background-color:AliceBlue;font-weight:bold" : "") + "'>" + (resultSet.getString("final_avg") == null ? " " : resultSet.getString("final_avg")) + "</td>"
                                    + "<td " + (request.getParameter("sort").equals("14") ? "style='background-color:AliceBlue;font-weight:bold" : "") + "'>" + resultSet.getString("total_avg") + "</td>"
                                    + "<td " + (request.getParameter("sort").equals("15") ? "style='background-color:AliceBlue;font-weight:bold" : "") + "'>" + (resultSet.getString("tournament_total_hc") == null ? " " : resultSet.getString("tournament_total_hc")) + "</td>"
                                    + "</tr>");
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
                <tr>
                    <td colspan="16">
                        <% if ((Boolean) session.getAttribute("Debug")) {
                                out.println(sqlQueryFinal.toString() + "<br/>");
                            }%>
                        <span style="color: red"><%= session.getAttribute("s_msg") != null ? session.getAttribute("s_msg") + "<br/>" : ""%></span>
                        <%session.removeAttribute("s_msg");%>
                    </td>
                </tr>
                <tr>
                    <td colspan="16">
                        <%=sortDesc%><br/>
                        Exporty: <a href="CsvExport?type=<%=session.getAttribute("tType")%>">[ ČBA - csv ]</a> GoodData - <a href="GDExportPlayers?type=<%=session.getAttribute("tType")%>">[ Players ]</a>
                    </td>
                </tr>
            </tfoot>

        </table>

        <%}%>
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
