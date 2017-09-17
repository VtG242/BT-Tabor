<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="VtGUtils.*"%>
<%@page import="java.sql.*,java.util.*"%>
<%! DbPool dbPool = null;

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
            int p = 0;
            int year;

            java.util.Calendar rightNow = java.util.Calendar.getInstance();
            if (request.getParameter("year") == null) {
                year = rightNow.get(Calendar.YEAR);
            } else {
                year = Integer.parseInt(request.getParameter("year"));
            }

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <link rel=StyleSheet href="css/tables.css" type="text/css"/>
        <script type="text/javascript" src="js/syear.js"></script>
        <title>BT - Body</title>
    </head>
    <body>

        <table>
            <caption>
                <form>
                    <select name="year" onChange="go(this.form,'tpoints.jsp')" size="1">
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
                    Body - celkové:
                </form>
            </caption>

            <thead><tr><th>&nbsp;</th><th>Hráč</th><th style="width: 40px">účast</th><th>body</th></tr></thead>
            <tbody>

                <%
                            try {

                                pstmt = conn.prepareStatement("SELECT player.psurname as psurname,player.pname as pname,count(tpresentation.pid) as pu,sum(body) as total FROM tpresentation,player,tround WHERE player.pid=tpresentation.pid AND tround.trid=tpresentation.trid AND EXTRACT(YEAR FROM tdate)=? GROUP BY player.psurname,player.pname ORDER BY total DESC,pu DESC");
                                pstmt.setInt(1, year);

                                resultSet = pstmt.executeQuery();

                                while (resultSet.next()) {
                                    p += 1;
                                    out.println("<tr><td>" + p + ".</td><td style='text-align: left;font-weight: bolder;'>" + resultSet.getString("psurname") + " " + resultSet.getString("pname") + "</td><td>" + resultSet.getString("pu") + "</td><td style='font-weight: bolder;'>" + resultSet.getString("total") + "</td></tr>");
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
                    <tr><td colspan="4"><span style="color: red"><%= session.getAttribute("s_msg") != null ? session.getAttribute("s_msg") + "<br/>" : ""%></span><%session.removeAttribute("s_msg");%></td></tr>
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
