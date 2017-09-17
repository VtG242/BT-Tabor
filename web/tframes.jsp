<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

    <head>
        <title>..:| BT - Bowlingové turnaje |:..</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    </head>

    <frameset rows="55,*" frameborder="0" framespacing="0" border="false" style="margin-top: 10px">

    <frame src="<%= response.encodeURL("tmenu.jsp")%>" marginwidth="0" frameborder="0" marginheight="0" noresize name="tmenu" scrolling="no"/>
    <frameset cols="255,*" frameborder="0" framespacing="0" border="false">
        <frame src="tleft.jsp"  name="tleft"/>
        <frame src="tright.jsp" name="tright"/>

        <noframes>
            <body bgcolor='white'>
                <div align="center">
                    <h1>BT - Bowlingové turnaje</h1>
                    Aplikace vyžaduje prohlížeč podporující rámy!
                    <br>
                    Aplication requires browser suporting frames!
                </div>
            </body>
        </noframes>

    </frameset>
    </frameset>

</html>
