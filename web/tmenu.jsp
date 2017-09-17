<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="VtGUtils.*"%>
<%@page import="java.sql.*"%>
<%!    DbPool dbPool = null;
    Connection conn = null;
    Statement stmt = null;
    ResultSet resultSet = null;
    String query = null;

    public void init() {
        dbPool = new DbPool("java:comp/env/jdbc/PgBTTabor");
    }
%>
<%
            Connection conn = dbPool.getDBConn();
            PreparedStatement pstmt = null;
            ResultSet resultSet = null;

            pstmt = conn.prepareStatement("SELECT tname FROM tdesc WHERE tid=?");
            pstmt.setInt(1, Integer.parseInt((String) session.getAttribute("tID")));
            resultSet = pstmt.executeQuery();
            resultSet.next();

            String tName = resultSet.getString(1);
            if (request.getParameter("switchdbg")!= null && request.getParameter("switchdbg").equals("true")) {
                session.setAttribute("Debug", (Boolean)session.getAttribute("Debug") ? false:true);
            }

            session.setAttribute("tName", tName);

%>
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <link rel=StyleSheet href="css/default.css" type="text/css"/>
        <title>BT - Bowlingové turnaje - menu</title>
        <base target="tleft"/>
    </head>
    <body>

        <fieldset style="font-weight: bolder;">
            <legend>Turnaj: <%= tName%></legend>
            [<a href='new.jsp' class="menu"> Nový </a>]
            &nbsp;
            [<a href='trunning.jsp' class="menu"> Probíhající </a>]
            &nbsp;
            [<a href='played.jsp' class="menu"> Odehrané </a>]
            &nbsp;
            [<a href='statsselect.jsp' class="menu"> Statistiky hráčů </a>]
            &nbsp;
            [<a href='tpointsselect.jsp' class="menu"> Bodování </a>]
            &nbsp;
            [<a href='index.jsp' class="menu" target="_top"> Výběr typu turnaje </a>]
            &nbsp;
            [<a href='tmenu.jsp?switchdbg=true' class="menu" target="_self"> Debug </a>: <%=(Boolean) session.getAttribute("Debug") ? "on" : "off"%> ]
        </fieldset>
    </body>
</html>
<%
            resultSet.close();
            pstmt.close();
            conn.close();
%>
