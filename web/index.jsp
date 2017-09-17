<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,java.util.regex.*"%>
<%@page import="VtGUtils.*"%>

<%!    DbPool dbPool = null;

    public void init() {
        dbPool = new DbPool("java:comp/env/jdbc/PgBTTabor");
    }
%>
<%
    //platnost session neomezena
    request.getSession(true);
    session.setMaxInactiveInterval(-1);

    //je-li zadan turnaj presmerujeme na stranku s menu:
    if (request.getParameter("turnament") != null) {
        String[] tIDtType = Pattern.compile("_").split(request.getParameter("turnament"));
        session.setAttribute("tID", tIDtType[0]);
        session.setAttribute("tType", tIDtType[1]);
        response.sendRedirect(response.encodeRedirectURL("tframes.jsp"));
    }
    session.setAttribute("Debug", false);
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
        <link rel=StyleSheet href="css/left.css" type="text/css"/>
        <title>BT - Bowlingové turnaje</title>
    </head>
    <body>

        <h1>BT - Bowlingové turnaje - verze 0.1</h1>

        <%= session.getAttribute("s_msg") == null ? "" : "<div id='" + ((Boolean) session.getAttribute("s_emsg") ? "emsg" : "msg") + "'>" + session.getAttribute("s_msg") + "</div>"%>
        <%session.setAttribute("s_msg", null);%>
        <%session.setAttribute("s_emsg", false);%>

        <fieldset id="ds">
            <legend>Výběr turnaje</legend>
            <form action="index.jsp" method="get">
                <select name="turnament">
                    <%
                        pstmt = conn.prepareStatement("SELECT tid,tname,ttype FROM tdesc ORDER BY ttype");
                        resultSet = pstmt.executeQuery();
                        while (resultSet.next()) {
                            out.print("<option value='" + resultSet.getInt(1) + "_" + resultSet.getString(3) + "'>" + resultSet.getString(3) + " - " + resultSet.getString(2) + "</option>");
                        }
                    %>
                </select>
                &nbsp;<input type="submit" class="submit" value="Zvolit"/>
            </form>
        </fieldset>

        <fieldset id="ds">
            <legend>Seznam hráčů</legend>
            <form action="AddPlayer" method="post">
                &nbsp;Jméno:<input type="text" name="name" size="20">
                    &nbsp;Příjmení:<input type="text" name="surname" size="20"> 
                        &nbsp; <input type="radio" name="sex" value="M" checked>Muž &nbsp;<input type="radio" name="sex" value="F">Žena
                                &nbsp;<input type="submit" class="submit" value="Přidat hráče"/>
                                </form>
                                <br/>
                                <%
                                    pstmt = conn.prepareStatement("SELECT pname,psurname FROM player ORDER BY psurname");
                                    resultSet = pstmt.executeQuery();
                                    while (resultSet.next()) {
                                        out.print(resultSet.getString(2) + " " + resultSet.getString(1) + "<br/>");
                                    }
                                %>        
                                </fieldset>

                                </body>
                                </html>
                                <%
                                    resultSet.close();
                                    pstmt.close();
                                    conn.close();
                                %>
