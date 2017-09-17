<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="VtGUtils.*"%>
<%@page import="java.sql.*"%>
<%! DbPool dbPool = null;

    public void init() {
        dbPool = new DbPool("java:comp/env/jdbc/PgBLTabor");
    }
%>
<%
    Connection conn = dbPool.getDBConn();
    PreparedStatement pstmt = null;
    ResultSet resultSet = null;
%>
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <link rel=StyleSheet href="css/default.css" type="text/css"/>
        <title>BT - Bowlingové turnaje - aktualizace hráčů</title>
        <base target="tright"/>
    </head>
    <body>
        <fieldset style="font-weight: bolder;" class="trunning">
            <legend>Hráči - aktualizace z ligy</legend>

            <form method="post" action="update-list.jsp">
                <fieldset style="font-weight: bolder; width: 90%">
                    <legend>Výpočet HC z:</legend>
                    <table>
                        <tr>
                            <td colspan="4">
                                <select name="season"  style="width: 184px;">
                                    <%
                                        pstmt = conn.prepareStatement("SELECT * FROM seasons ORDER BY sid");
                                        resultSet = pstmt.executeQuery();
                                        while (resultSet.next()) {
                                            out.print("<option value='" + resultSet.getInt(1) + "'>" + resultSet.getString(2) + "</option>");
                                        }
                                    %>
                                </select>
                            </td>
                        </tr>
                        <tr><td colspan="4" align="center"><input type="submit" value="aktualizovat" style="width: 180px;"/></td></tr>
                    </table>
                </fieldset>
            </form>

        </fieldset>
    </body>
</html>
<%
    resultSet.close();
    pstmt.close();
    conn.close();
%>
