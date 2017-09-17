<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="VtGUtils.*"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*" %>
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
            int p = 1;
            int year;

            java.util.Calendar rightNow = java.util.Calendar.getInstance();
            if (request.getParameter("year") == null) {
                year = rightNow.get(Calendar.YEAR);
            } else {
                year = Integer.parseInt(request.getParameter("year"));
            }

            String sqlQuery =
                    "SELECT "
                    + "player.psurname as psurname,"
                    + "player.pname as pname,"
                    + "player.pgender as pgender,"
                    + "count(*) as pz,"
                    + "max(gscore) as max,"
                    + "min(gscore) as min,"
                    + "to_char(round (avg(gscore),2),'999D99') AS avgprint,"
                    + "round (avg(gscore),2) AS avg,"
                    + "round ((160-avg(gscore))/3,0) as hc "
                    + "FROM tscore,tround,tdesc,player "
                    + "WHERE tscore.trid = tround.trid "
                    + "AND tscore.pid = player.pid "
                    + "AND tdesc.tid=tround.tid "
                    + "AND (tdesc.ttype='B' OR tdesc.ttype='A') "
                    + "AND to_char(tround.tdate,'YYYY')=? "
                    + "AND tround.tend='Y'"
                    + "GROUP BY player.psurname, player.pname, player.pgender "
                    + "ORDER BY avg DESC";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <link rel=StyleSheet href="css/tables.css" type="text/css"/>
        <script type="text/javascript" src="js/syear.js"></script>
        <title>BT - Statistiky celkové</title>
    </head>
    <body>

        <table>
            <caption>
                <form>                   
                    <select name="year" onChange="go(this.form,'statsAB.jsp')" size="1">
                        <option value="2013">2013</option>
                        <%
                                    try {

                                        pstmt = conn.prepareStatement("SELECT DISTINCT EXTRACT(YEAR FROM tdate) as tyear FROM tround ORDER BY tyear");
                                        resultSet = pstmt.executeQuery();

                                        while (resultSet.next()) {
                                            out.println("<option value=" + resultSet.getInt("tyear") + " " + (resultSet.getInt("tyear") == year ? "selected" : "") + ">" + resultSet.getInt("tyear") + "</option>");
                                        }

                                    } catch (SQLException e) {
                                        if (session.getAttribute("s_msg") == null) {
                                            session.setAttribute("s_msg", "Chyba SQL: " + e.getMessage());
                                        } else {
                                            session.setAttribute("s_msg", (session.getAttribute("s_msg") + "<br/>Chyba SQL: " + e.getMessage()));
                                        }
                                    }
                        %>
                    </select>
                    Statistiky AB:
                </form>
            </caption>
            <thead>
                <tr><th></th><th>Hráč</th><th>PZ</th><th>HCZ</th><th>HCV</th><th>Max</th><th>Min</th><th>&empty;</th></tr>
            </thead>
            <tbody>
                <%
                            try {

                                pstmt = conn.prepareStatement(sqlQuery);
                                pstmt.setString(1, Integer.toString(year));
                                resultSet = pstmt.executeQuery();

                                int hcz, hcv = 0;
                                double avg = 0.00;

                                while (resultSet.next()) {
                                    avg = resultSet.getDouble("avg");
                                    if (resultSet.getString("pgender").equals("F")) {
                                        if (avg >= 180) {
                                            hcz = 4;
                                        } else {
                                            hcz = 8;
                                        }
                                    } else {
                                        hcz = 0;
                                    }
                                    if (resultSet.getInt("hc")>=0) {
                                        hcv = resultSet.getInt("hc");
                                    } else {
                                        hcv = 0;
                                    }
                                    out.println("<tr><td>" + p + ".</td>"
                                            + "<td style='text-align:left;font-weight: bolder'>" + resultSet.getString("psurname") + " " + resultSet.getString("pname") + "</td>"
                                            + "<td>" + resultSet.getString("pz") + "</td>"
                                            + "<td>" + hcz + "</td>"
                                            + "<td>" + hcv + "</td>"
                                            + "<td>" + resultSet.getString("max") + "</td>"
                                            + "<td>" + resultSet.getString("min") + "</td>"
                                            + "<td style='font-weight: bolder'>" + resultSet.getString("avgprint") + "</td>"
                                            + "</tr>");
                                    p++;
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
                <tr><td colspan="8"><span style="color: red"><%= session.getAttribute("s_msg") != null ? session.getAttribute("s_msg") + "<br/>" : ""%></span><%session.removeAttribute("s_msg");%></td></tr>
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