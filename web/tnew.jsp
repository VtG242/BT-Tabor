<%-- 
    Document   : lround-ridadd
    Created on : 10.11.2013, 10:20:01
    Author     : VtG
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>

    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel=StyleSheet href="css/left.css" type="text/css"/>
        <link rel=StyleSheet href="css/ratable.css" type="text/css"/>
        <title>BT - přidání turnaje</title>
        <base target="tright"/>
        <!-- calendar stylesheet -->
        <link rel="stylesheet" type="text/css" media="all" href="calendar/calendar-system.css" title="calendar-system" />
        <!-- main calendar program -->
        <script type="text/javascript" src="calendar/calendar.js"></script>
        <!-- language for the calendar -->
        <script type="text/javascript" src="calendar/lang/calendar-en.js"></script>
        <!-- the following script defines the Calendar.setup helper function, which makes
        adding a calendar a matter of 1 or 2 lines of code. -->
        <script type="text/javascript" src="calendar/calendar-setup.js"></script>
    </head>

    <body>

        <form method="post" action="AddTournament">

            <table border="0" style="margin-top: 15px">
                <thead>
                    <tr>
                        <th colspan="2"><strong>Nový turnaj</strong></th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>Typ turnaje:</td>
                        <td>
                            <select name="ttype" style="width: 150px">
                                <option value=''> --- </option>
                                <option value='1'>A - Amerika</option><option value='2'>B - Normal</option><option value='3'>C - Devítka</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td>&nbsp;Datum(dd.mm.rrrr):&nbsp;</td>
                        <td>
                            <table border="0" cellpadding="0" cellspacing="0"><tr><td><input  style="width: 122px" type="text" name="date" value="" id="f_date_c" readonly="1" style="width: 80px;"/></td><td><img src="img/img.gif" id="f_trigger_c" style="cursor: pointer; border: 1px solid blue;" title="Výběr datumu" onmouseover="this.style.background = 'blue';" onmouseout="this.style.background = 'white';"/></td></tr></table>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <input type="submit" value="přidat turnaj"><br/><br/>
                        </td>
                    </tr>
                </tbody>
            </table>
            <%= session.getAttribute("s_msg") == null ? "" : "<div id='" + ((Boolean)session.getAttribute("s_emsg") ? "emsg":"msg") + "'>" + session.getAttribute("s_msg") + "</div>"%>
            <%session.setAttribute("s_msg", null);%>
            <%session.setAttribute("s_emsg", false);%>
        </form>

        <script type="text/javascript">
                                Calendar.setup({
                                    inputField: "f_date_c", // id of the input field
                                    ifFormat: "%d.%m.%Y", // format of the input field
                                    button: "f_trigger_c", // trigger for the calendar (button ID)
                                    align: "Tl", // alignment (defaults to "Bl")
                                    singleClick: true
                                });
        </script>

    </body>

</html>
