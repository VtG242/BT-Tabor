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
        <title>BT - Bowlingové turnaje - aktualizace hráčů - výpis</title>
        <base target="tright"/>
    </head>
    <body>
        <%
            pstmt = conn.prepareStatement("SELECT pid,pname,psurname,pgender,getplayeravg(pid,2) FROM players ORDER BY psurname,pname");
            resultSet = pstmt.executeQuery();
            while (resultSet.next()) {
                out.print(resultSet.getInt(1) + " " +resultSet.getString(3) + " " +resultSet.getString(2) + " " + resultSet.getString(5) + "</br>");
            }
        %>
    </body>
</html>
<%
    resultSet.close();
    pstmt.close();
    conn.close();
%>
