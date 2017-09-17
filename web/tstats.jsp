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
            int p = 1;
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <link rel=StyleSheet href="css/stats.css" type="text/css"/>
        <title>BT - Turnajové statistiky</title>
    </head>
    <body>
        <table style="float: left;margin-right: 15px;">
            <thead>
                <tr><th colspan="6">Muži</th></tr>
            </thead>
            <tr><th colspan="3">Nejvysší nához: </th></tr>
            <tbody>
                <%
                            try {
                                sqlQuery = "SELECT psurname,pname,gscore FROM tscore,player WHERE trid=? AND tscore.pid=player.pid AND pgender='M' ORDER BY gscore DESC,psurname;";
                                pstmt = conn.prepareStatement(sqlQuery, ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
                                pstmt.setInt(1, (Integer) session.getAttribute("trID"));

                                resultSet = pstmt.executeQuery();

                                while (resultSet.next()) {
                %>
                <tr>
                    <td><%=p%>.</td><td style="text-align: left;"><%=resultSet.getString("psurname") + " " + resultSet.getString("pname")%></td><td><%=resultSet.getString("gscore")%></td>
                </tr>
                <%
                                                    p += 1;
                                                    if (p == 6) {
                                                        break;
                                                    }
                                                }

                                                resultSet.afterLast();
                                                p = 1;

                %>
                <tr><th colspan="3">Nejnizší nához: </th></tr>
                <%
                                                while (resultSet.previous()) {
                %>
                <tr>
                    <td><%=p%>.</td><td style="text-align: left;"><%=resultSet.getString("psurname") + " " + resultSet.getString("pname")%></td><td><%=resultSet.getString("gscore")%></td>
                </tr>
                <%
                                    p += 1;
                                    if (p == 6) {
                                        break;
                                    }
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
                    <td colspan="3">
                        <span style="color: red"><%= session.getAttribute("s_msg") != null ? session.getAttribute("s_msg") + "<br/>" : ""%></span>
                        <%session.removeAttribute("s_msg");%>
                    </td>
                </tr>
            </tfoot>

        </table>

        <table>
            <thead>
                <tr><th colspan="6">Ženy</th></tr>
            </thead>
            <tr><th colspan="3">Nejvysší nához: </th></tr>
            <tbody>
                <%
                            try {
                                p = 1;
                                sqlQuery = "SELECT psurname,pname,gscore FROM tscore,player WHERE trid=? AND tscore.pid=player.pid AND pgender='F' ORDER BY gscore DESC,psurname;";
                                pstmt = conn.prepareStatement(sqlQuery, ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
                                pstmt.setInt(1, (Integer) session.getAttribute("trID"));

                                resultSet = pstmt.executeQuery();

                                while (resultSet.next()) {
                %>
                <tr>
                    <td><%=p%>.</td><td style="text-align: left;"><%=resultSet.getString("psurname") + " " + resultSet.getString("pname")%></td><td><%=resultSet.getString("gscore")%></td>
                </tr>
                <%
                                                    p += 1;
                                                    if (p == 6) {
                                                        break;
                                                    }
                                                }

                                                resultSet.afterLast();
                                                p = 1;

                %>
                <tr><th colspan="3">Nejnizší nához: </th></tr>
                <%
                                                while (resultSet.previous()) {
                %>
                <tr>
                    <td><%=p%>.</td><td style="text-align: left;"><%=resultSet.getString("psurname") + " " + resultSet.getString("pname")%></td><td><%=resultSet.getString("gscore")%></td>
                </tr>
                <%
                                    p += 1;
                                    if (p == 6) {
                                        break;
                                    }
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
                    <td colspan="3">
                        <span style="color: red"><%= session.getAttribute("s_msg") != null ? session.getAttribute("s_msg") + "<br/>" : ""%></span>
                        <%session.removeAttribute("s_msg");%>
                    </td>
                </tr>
            </tfoot>

        </table>


        <table>
            <thead>
                <tr><th colspan="2">Počet startů</th></tr>
            </thead>
            <tbody>
                <%
                            try {
                                int psr = 0;
                                int ps = 0;

                                sqlQuery = "SELECT count(*) FROM (SELECT pid FROM tscore WHERE trid=? GROUP BY pid,tstart) AS psr";
                                pstmt = conn.prepareStatement(sqlQuery);
                                pstmt.setInt(1, (Integer) session.getAttribute("trID"));
                                resultSet = pstmt.executeQuery();
                                resultSet.next();
                                psr = resultSet.getInt(1);

                                sqlQuery = "SELECT count(*) FROM (SELECT pid FROM tscore WHERE trid=? AND tcount='Y' GROUP BY pid) AS ps";
                                pstmt = conn.prepareStatement(sqlQuery);
                                pstmt.setInt(1, (Integer) session.getAttribute("trID"));
                                resultSet = pstmt.executeQuery();
                                resultSet.next();
                                ps = resultSet.getInt(1);
                %>
                <tr><td>celkem: <%=psr%></td><td>restarty: <%= psr-ps%></td></tr>
                <%

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
                    <td colspan="8">
                        <span style="color: red"><%= session.getAttribute("s_msg") != null ? session.getAttribute("s_msg") + "<br/>" : ""%></span>
                        <%session.removeAttribute("s_msg");%>
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
