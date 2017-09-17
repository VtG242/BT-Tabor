<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="VtGUtils.*,java.sql.*"%>
<%!    DbPool dbPool = null;

    public void init() {
        dbPool = new DbPool("java:comp/env/jdbc/PGpoolBT");
    }
%>
<%
            //platnost session neomezena
            request.getSession(true);
            session.setMaxInactiveInterval(-1);

            //nastaveni stalych promenych do session
            session.setAttribute("backURL", "tStepResults.jsp?step=1&sort=7");

            //inicializace promenych pro trideni
            int sortType = Integer.parseInt(request.getParameter("sort"));
            int step = Integer.parseInt(request.getParameter("step"));
            String sort = "";
            String sortDesc = "&nbsp;";

            //cisla oznacuji sloupce v zobrazene html tabulce
            switch (sortType) {
                case 2: //trideni podle prijmeni
                    sort = "psurname, pname, step_total_hc DESC, step_total DESC";
                    sortDesc = "Metodika třídění: Příjmení (abecedně) -> Jméno (abecedně) <img src='img/desc.jpg'/> Celkový nához s HC";
                    break;
                case 3: //HC
                    sort = "hc DESC,psurname, pname";
                    sortDesc = "Metodika třídění: HC <img src='img/desc.jpg'/> ";
                    break;
                case 5: //suma HC
                    sort = "hc DESC,psurname, pname";
                    sortDesc = "Metodika třídění: HC <img src='img/desc.jpg'/> ";
                    break;
                case 6: //step_total
                    sort = "step_total DESC, hc, smax DESC, pomscr DESC";
                    sortDesc = "Metodika třídění: <img src='img/desc.jpg'/> Celkový součet bez HC <img src='img/asc.jpg'/> HC <img src='img/desc.jpg'/> Nejvysší nához";
                    break;
                case 7: //step_total_hc
                    sort = "step_total_hc DESC, step_total DESC, smax DESC, pomscr DESC";
                    sortDesc = "Metodika třídění: <img src='img/desc.jpg'/> Celkový součet s HC <img src='img/desc.jpg'/> Celkový součet bez HC <img src='img/desc.jpg'/> Nejvysší nához";
                    break;
                case 8: //step_avg
                    sort = "total_avg DESC, smax DESC, pomscr DESC";
                    sortDesc = "Metodika třídění: <img src='img/desc.jpg'/> Průměr z kvalifikace <img src='img/desc.jpg'/> Nejvysší nához";
                    break;
                case 9: //runda
                    sort = "tround, step_total_hc DESC, step_total DESC, smax DESC, pomscr DESC";
                    sortDesc = "Metodika třídění: <img src='img/asc.jpg'/> Runda <img src='img/desc.jpg'/> Celkový součet s HC <img src='img/desc.jpg'/> Celkový součet bez HC <img src='img/desc.jpg'/> Nejvysší nához";
                    break;
                case 10: //runda
                    sort = "tstart, step_total_hc DESC, step_total DESC, smax DESC, pomscr DESC";
                    sortDesc = "Metodika třídění: <img src='img/asc.jpg'/> Start <img src='img/desc.jpg'/> Celkový součet s HC <img src='img/desc.jpg'/> Celkový součet bez HC <img src='img/desc.jpg'/> Nejvysší nához";
                    break;
            }

            Connection conn = dbPool.getDBConn();
            PreparedStatement pstmt = null;
            ResultSet resultSet = null;
            String sqlQuery =
                    "SELECT "
                    + "tscore.tround AS tround,"
                    + "tscore.tstart AS tstart,"
                    + "player.pid AS pid,"
                    + "player.psurname AS psurname,"
                    + "player.pname AS pname,"
                    + "getplayerroundhc(tscore.trid,player.pid) AS hc,"
                    + "getplayerscorer(tscore.pid,tscore.trid,tscore.tstep,tscore.tstart) AS step_score,"
                    + "getplayersumr(tscore.pid,tscore.trid,tscore.tstep,tscore.tstart) AS step_total,"
                    + "playersumhc(tscore.pid,tscore.trid,tscore.tstep,tscore.tstart) AS step_hc,"
                    + "getplayersumtotalr(tscore.pid,tscore.trid,tscore.tstep,tscore.tstart) AS step_total_hc,"
                    + "getplayertotalavgr(tscore.pid,tscore.trid,tscore.tstep,tscore.tstart) AS total_avg,"
                    + "getplayermaxstepscr(tscore.pid,tscore.trid,tscore.tstep) AS smax,"
                    + "getplayerpomscr(tscore.pid,tscore.trid,tscore.tstep,tscore.tstart) as pomscr,"
                    + "tscore.tcount as tcount "
                    + "FROM tscore,player "
                    + "WHERE tscore.trid=? AND tscore.tstep=? AND player.pid=tscore.pid "
                    + "GROUP BY tscore.trid, tscore.pid, tscore.tround, tscore.tstep, tscore.tstart, tscore.tcount, player.pid, player.psurname, player.pname "
                    + "ORDER BY " + sort;
            int p = 0;
            int pom = 1;
%>
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <link rel=StyleSheet href="css/tables.css" type="text/css"/>
        <title>BT - Bowlingové turnaje - Kvalifikace</title>
    </head>
    <body>
        <table>
            <caption><%= step == 1 ? "K V A L I F I K A C E" : "F I N Á L E"%> </caption>
            <thead>
                <tr align="center">
                    <th>&nbsp;</th>
                    <th><a href="?step=<%=step%>&sort=2">hráč</a></th>
                    <th><a href="?step=<%=step%>&sort=3">HC</a></th>
                    <th>scóre</th>
                    <th><a href="?step=<%=step%>&sort=5">&nbsp;&sum;HC&nbsp;</a></th>
                    <th><a href="?step=<%=step%>&sort=6">&nbsp;&sum;&nbsp;</a></th>
                    <th><a href="?step=<%=step%>&sort=7" title="Celkový součet bodů z odehraných her + součet handicapů">&sum;HC+&sum;</a></th>
                    <th><a href="?step=<%=step%>&sort=8">&nbsp;&empty;&nbsp;</a></th>
                    <th>&nbsp;</th>
                    <th><a href="?step=<%=step%>&sort=9">runda</a></th>
                    <th><a href="?step=<%=step%>&sort=10">start</a></th>
                    <th>&nbsp;</th>
                </tr>
            </thead>
            <tbody>
                <%
                            try {
                                pstmt = conn.prepareStatement(sqlQuery);
                                pstmt.setInt(1, (Integer) session.getAttribute("trID"));
                                pstmt.setInt(2, step);

                                resultSet = pstmt.executeQuery();

                                while (resultSet.next()) {

                                    //je-li zadan pozadavek trideni dle rundy - cislujeme poradi od 1. v kazde runde a zobrazujeme i restarty
                                    if (request.getParameter("sort").equals("9")) {
                                        if (resultSet.getInt("tround") != pom) {
                                            p = 0;
                                            out.print("<tr><td colspan='12'><strong>" + resultSet.getInt("tround") + ". runda</strong></tr>");
                                        }
                                        pom = resultSet.getInt("tround");
                                    } else {
                                        if (resultSet.getString("tcount").equals("N")) {
                                            continue; // pro ostatni zobrazeni restarty nezobrazujeme
                                        }
                                    }
                                    //zjisteni akce pro aktualni tcount
                                    String tCountState = resultSet.getString("tcount").equals("N") ? "Y" : "N";
                                    p += 1;

                                    out.print("<tr>"
                                            + "<td " + (resultSet.getInt("pomscr") > 0 ? "style='background-color:yellow'" : "") + ">" + ((request.getParameter("sort").equals("2")) ? " " : p + ".") + "&nbsp;</td>"
                                            + "<td style='text-align:left;font-weight:bold;" + (request.getParameter("sort").equals("2") ? "background-color:AliceBlue;" : "") + "'>" + resultSet.getString("psurname") + " " + resultSet.getString("pname") + "</td>"
                                            + "<td " + (request.getParameter("sort").equals("3") ? "style='background-color:AliceBlue;font-weight:bold'" : "") + ">" + resultSet.getString("hc") + "</td>"
                                            + "<td>" + resultSet.getString("step_score") + "</td>"
                                            + "<td " + (request.getParameter("sort").equals("5") ? "style='background-color:AliceBlue;font-weight:bold'" : "") + ">" + resultSet.getString("step_hc") + "</td>"
                                            + "<td " + (request.getParameter("sort").equals("6") ? "style='background-color:AliceBlue;font-weight:bold'" : "") + ">" + resultSet.getString("step_total") + "</td>"
                                            + "<td " + (request.getParameter("sort").equals("7") ? "style='background-color:AliceBlue;font-weight:bold'" : "") + ">" + resultSet.getString("step_total_hc") + "</td>"
                                            + "<td " + (request.getParameter("sort").equals("8") ? "style='background-color:AliceBlue;font-weight:bold'" : "") + ">" + resultSet.getString("total_avg") + "</td>"
                                            + "<td>&nbsp;</td>"
                                            + "<td " + (request.getParameter("sort").equals("9") ? "style='background-color:AliceBlue;font-weight:bold'" : "") + ">" + resultSet.getInt("tround") + "</td>"
                                            + "<td " + (request.getParameter("sort").equals("10") ? "style='background-color:AliceBlue;font-weight:bold'" : "") + ">" + resultSet.getInt("tstart") + "</td>"
                                            + "<td><a href='Tcount?pid=" + resultSet.getString("pid") + "&start=" + resultSet.getString("tstart") + "&state=" + tCountState + "'>[ " + (tCountState.equals("Y") ? "&#8330;" : "&#8331;") + " ]</a></td>"
                                            + "</tr>");
                                }

                            } catch (SQLException e) {
                                if (session.getAttribute("s_msg") == null) {
                                    session.setAttribute("s_msg", "Chyba SQL:" + e.getMessage());
                                } else {
                                    session.setAttribute("s_msg", session.getAttribute("s_msg") + "<br/>Chyba SQL:" + e.getMessage());
                                }
                            }
                %>
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="12">
                        <% if ((Boolean) session.getAttribute("Debug")) {
                                        out.println(sqlQuery+"<br/>");
                                    }%>
                        <span style="color: red"><%= session.getAttribute("s_msg") != null ? session.getAttribute("s_msg") + "<br/>" : ""%></span>
                        <%session.removeAttribute("s_msg");%>
                    </td>
                </tr>
                <tr>
                    <td colspan="12">
                        <%=sortDesc%>
                    </td>
                </tr>
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
