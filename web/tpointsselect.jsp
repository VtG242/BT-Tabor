<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="VtGUtils.*"%>
<%
            request.getSession(true);
            session.setMaxInactiveInterval(-1);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <link rel=StyleSheet href="css/default.css" type="text/css"/>
        <title>BT - Body</title>
        <base target="tright"/>
    </head>
    <body>
        <fieldset style="font-weight: bolder;" class="trunning">
            <legend>Body</legend>
            <ul>
                <li><a href='' class='menu'>(A) Amerika</a></li>
                <li><a href='' class='menu'>(B) Normal </a></li>
                <li><a href='' class='menu'>(C) Devítka</a></li>
                <li><a href='tpoints.jsp' class='menu'>Celkové (A,B,C)</a></li>
            </ul>
        </fieldset>
    </body>
</html>
