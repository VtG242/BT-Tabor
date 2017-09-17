<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="VtGUtils.*"%>
<%@page import="java.sql.*"%>
<%! DbPool dbPool = null;

    public void init() {
        dbPool = new DbPool("java:comp/env/jdbc/PgBTTabor");
    }
%>
<%
    Connection conn = dbPool.getDBConn();
    PreparedStatement pstmt = null;
    ResultSet resultSet = null;
    int trID = 0;
    String tDate = "";

    pstmt = conn.prepareStatement("SELECT trid,to_char(tdate,'DD.MM. YYYY') FROM tround WHERE tid=? AND tend=?");
    pstmt.setInt(1, Integer.parseInt((String) session.getAttribute("tID")));
    pstmt.setString(2, String.valueOf('N'));
    resultSet = pstmt.executeQuery();

    //vzdy by mel byt probihajici jen jeden turnaj v dane kategorii
    while (resultSet.next()) {
        trID = resultSet.getInt(1);
        tDate = resultSet.getString(2);
        //nastaveni stalych promenych do session
        session.setAttribute("trID", trID);
    }
%>
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <link rel=StyleSheet href="css/default.css" type="text/css"/>
        <script type="text/javascript" src="js/addscore.js"></script>
        <title>BT - Bowlingové turnaje - menu</title>
        <base target="tright"/>
    </head>
    <body>
        <%
            if (trID > 0) {
        %>
        <fieldset style="font-weight: bolder;" class="trunning">
            <legend><%= tDate%></legend>
            <ul>
                <li><a href='tattendance.jsp' class='menu'>Prezence</a></li>
                <li><a href='tStepResults.jsp?step=1&sort=7' class='menu'>Kvalifikace</a></li>
                <li><a href='tStepResults.jsp?step=2&sort=7' class='menu'>Finále</a></li>
                <li><a href='tresult.jsp?sort=<%= session.getAttribute("tType").equals("C") || session.getAttribute("tType").equals("A") ? "15" : "15"%>' class='menu'>Celkové výsledky</a></li>
                <li><a href='tstats.jsp' class='menu'>Statistiky</a></li>
            </ul>

            <form method="post" action="AddScore" name="AddScore">
                <fieldset style="font-weight: bolder; width: 90%">
                    <legend>Odehrané hry</legend>
                    <table>
                        <tr>
                            <td colspan="4">
                                <select name="player" style="width: 184px;">
                                    <%
                                        pstmt = conn.prepareStatement("SELECT tpresentation.pid as pid,psurname,pname,hc FROM tpresentation,player WHERE tpresentation.pid=player.pid AND tpresentation.trid=? ORDER BY psurname");
                                        pstmt.setInt(1, trID);

                                        resultSet = pstmt.executeQuery();
                                        while (resultSet.next()) {
                                            out.println("<option value='" + resultSet.getString("pid") + "_" + resultSet.getString("hc") + "'>" + resultSet.getString("psurname") + " " + resultSet.getString("pname") + " (" + resultSet.getString("hc") + ")</option>");
                                        }
                                    %>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="4">
                                <select name="tstep"  style="width: 184px;">
                                    <option value="1">1 - kvalifikace</option>
                                    <option value="2">2 - finále</option>
                                </select>
                            </td>
                        </tr>

                        <tr><td>runda</td><td>start</td><td colspan="2">score</td></tr>
                        <tr>
                            <td>
                                <select name="tround" style="width: 60px;">
                                    <option value="0">0</option><option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option>
                                </select>
                            </td>
                            <td>
                                <select name="tstart" style="width: 60px;">
                                    <option value="1">1</option><option value="2">2</option><option value="3">3</option>
                                </select>
                            </td>
                            <td colspan="2"><input type="text" name="tscore" size="3" onkeypress="{
                                        if (event.keyCode == 13)
                                            gameSubmit()
                                    }"/></td>
                        </tr>
                        <tr><td colspan="4" align="center"><input type="button" value="uložit" onclick="gameSubmit()" style="width: 180px;"/></td></tr>
                    </table>
                </fieldset>
            </form>

            <ul>
                <li><a href='tqualifedit.jsp?sort=1' class='menu'>Opravy</a></li>
                <li><a href='Tfinish' class='menu'>Ukončení turnaje</a></li>
            </ul>

            <form method="post" action="Find" name="find">
                <fieldset style="font-weight: bolder; width: 90%">
                    <legend>Vyhledat</legend>
                    <table>
                        <tr>
                            <td><input type="text" name="find" size="20"/></td>
                        </tr>
                        <tr>
                            <td align="center"><input type="submit" value="Najít"/></td>
                        </tr>
                    </table>
                </fieldset>
            </form>

        </fieldset>
        <%
        } else {
            pstmt = conn.prepareStatement("SELECT trid,to_char(tdate,'DD.MM. YYYY') as tdate FROM tround WHERE tid=?");
            pstmt.setInt(1, Integer.parseInt((String) session.getAttribute("tID")));
            resultSet = pstmt.executeQuery();
        %>
        <table>
            <tr><td>Žádný turnaj není nastaven jako probíhající - jaký turnaj otevřít?:</td></tr>
            <%
                while (resultSet.next()) {
                    out.println("<tr><td><a href='OpenTurnament?trid=" + resultSet.getString("trid") + "' target='_self'>" + resultSet.getString("tdate") + "<a></td></tr>");
                }
            %>
        </table>
        <%
            }
            resultSet.close();
            pstmt.close();
            conn.close();
        %>
    </body>
</html>
