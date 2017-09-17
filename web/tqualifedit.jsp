<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="VtGUtils.*"%>
<%@page import="java.sql.*"%>
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
            session.setAttribute("backURL", "tqualifedit.jsp?sort=1");

            //inicializace promenych pro trideni
            String sort = "";
            String sortDesc = "&nbsp;";

            //cisla oznacuji sloupce v zobrazene html tabulce
            switch (Integer.parseInt(request.getParameter("sort"))) {

                case 1: //trideni podle prijmeni
                    sort = "tstep, qualif_total_hc DESC, qualif_total DESC";
                    break;
                case 2: //trideni podle prijmeni
                    sort = "psurname, pname, tstep, qualif_total_hc DESC, qualif_total DESC";
                    break;
                case 5: //qualif_total
                    sort = "qualif_total DESC, hc";
                    break;
                case 6: //qualif_avg
                    sort = "total_avg DESC";
                    break;
                case 7: //qualif_total_hc
                    sort = "qualif_total_hc DESC, qualif_total DESC";
                    break;
                case 9: //runda
                    sort = "tround, tstep";
                    sortDesc = "Metodika třídění: Runda (vzestupně) -> Celkový součet s HC (sestupně) -> Celkový součet bez HC (sestupně)";
                    break;
            }

            Connection conn = dbPool.getDBConn();
            PreparedStatement pstmt = null;
            ResultSet resultSet = null;
            String sqlQuery =
                    "SELECT "
                    + "tscore.tstep AS tstep,"
                    + "tscore.tround AS tround,"
                    + "tscore.tstart AS tstart,"
                    + "player.pid AS pid,"
                    + "player.psurname AS psurname,"
                    + "player.pname AS pname,"
                    + "getplayerscorer(tscore.pid,tscore.trid,tscore.tstep,tscore.tstart) as qualif_score,"
                    + "getplayersumr(tscore.pid,tscore.trid,tscore.tstep,tscore.tstart) as qualif_total,"
                    + "getplayertotalavgr(tscore.pid,tscore.trid,tscore.tstep,tscore.tstart) as total_avg,"
                    + "getplayersumtotalr(tscore.pid,tscore.trid,tscore.tstep,tscore.tstart) as qualif_total_hc,"
                    + "tscore.tcount AS tcount, "
                    + "tpresentation.hc AS hc "
                    + "FROM tscore,player,tpresentation "
                    + "WHERE tscore.trid=? AND player.pid=tscore.pid AND player.pid=tpresentation.pid "
                    + "GROUP BY tscore.tstep,tscore.trid, tscore.pid, tscore.tround, tscore.tstart, tscore.tstep, tscore.tcount, player.pid, player.psurname, player.pname, tpresentation.hc "
                    + "ORDER BY " + sort;
%>
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <link rel=StyleSheet href="css/default.css" type="text/css"/>
        <title>BT - Bowlingové turnaje - Kvalifikace</title>
        <style type="text/css">
            table
            {
                border-collapse:collapse;
            }
            table, td, th
            {
                border:1px solid black;
                padding: 0px 5px 0px 10px;
                text-align: center;
            }
            th
            {
                background-color:silver;
                color:white;
            }
        </style>
    </head>
    <body>

        <div id="msg"><%= session.getAttribute("s_msg") != null ? session.getAttribute("s_msg") : ""%></div>
        <%session.removeAttribute("s_msg");%>

        <table border="1" style="margin-top:10px">
            <tr>
                <th colspan="11" align="center" style="color:black">Výpis všech odehraných her</th>
            </tr>

            <tr align="center">
                <th><a href="tqualifedit.jsp?sort=1">krok</a></th>
                <th><a href="tqualifedit.jsp?sort=2">hráč</a></th>
                <th>HC</th>
                <th>scóre</th>
                <th><a href="tqualifedit.jsp?sort=5">součet</a></th>
                <th><a href="tqualifedit.jsp?sort=6">průměr</a></th>
                <th><a href="tqualifedit.jsp?sort=7">součet+HC</a></th>
                <th>&nbsp;</th>
                <th><a href="tqualifedit.jsp?sort=9">runda</a></th>
                <th>start</th>
                <th>&nbsp;</th>
            </tr>
            <%
                        //try {
                        pstmt = conn.prepareStatement(sqlQuery);
                        pstmt.setInt(1, (Integer) session.getAttribute("trID"));
                        //pstmt.setString(2,(String)session.getAttribute("tsort"));

                        resultSet = pstmt.executeQuery();

                        while (resultSet.next()) {

                            //zjisteni akce pro aktualni tcount
                            String tCountState = resultSet.getString("tcount").equals("N") ? "Y" : "N";

                            out.print("<tr>"
                                    + "<td style='text-align:left;background-color:" + (request.getParameter("sort").equals("1") ? "AliceBlue" : "white") + "'>" + (resultSet.getString("tstep").equals("1") ? "1 - kval." : "2 - finále") + "</td>"
                                    + "<td style='text-align:left;background-color:" + (request.getParameter("sort").equals("2") ? "AliceBlue" : "white") + "'><a href='Tedit?pid=" + resultSet.getString("pid") + "'>" + resultSet.getString("psurname") + " " + resultSet.getString("pname") + "</a></td>"
                                    + "<td>" + resultSet.getString("hc") + "</td>"
                                    + "<td>" + resultSet.getString("qualif_score") + "</td>"
                                    + "<td style='text-align:center;background-color:" + (request.getParameter("sort").equals("5") ? "AliceBlue" : "white") + "'>" + resultSet.getString("qualif_total") + "</td>"
                                    + "<td style='text-align:center;background-color:" + (request.getParameter("sort").equals("6") ? "AliceBlue" : "white") + "'>" + resultSet.getString("total_avg") + "</td>"
                                    + "<td style='text-align:center;background-color:" + (request.getParameter("sort").equals("7") ? "AliceBlue" : "white") + "'>" + resultSet.getString("qualif_total_hc") + "</td>"
                                    + "<td>&nbsp;</td>"
                                    + "<td style='text-align:center;background-color:" + (request.getParameter("sort").equals("9") ? "AliceBlue" : "white") + "'>" + resultSet.getInt("tround") + "</td>"
                                    + "<td>" + resultSet.getString("tstart") + "</td>"
                                    + "<td><a href='Tcount?pid=" + resultSet.getString("pid") + "&start=" + resultSet.getString("tstart") + "&state=" + tCountState + "'>[ " + (tCountState.equals("Y") ? "+" : "-") + " ]</a></td>"
                                    + "</tr>");
                        }

                        //out.print("<div align=center>DEBUG: " + sqlQuery + "</div>");

                        //} catch (SQLException e) {
                        //     out.println("Chyba SQL:" + e.getMessage());
                        //     conn.close();
                        // }
            %>
        </table>
    </body>
</html>
<%
            resultSet.close();
            pstmt.close();
            conn.close();
%>
