<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="VtGUtils.*"%>
<%@page import="java.sql.*"%>
<%@page errorPage="./error.jsp"%>
<%!    DbPool dbPool = null;

    public void init() {
        dbPool = new DbPool("java:comp/env/jdbc/PgBTTabor");
    }
%>
<%
    //platnost session neomezena
    request.getSession(true);
    session.setMaxInactiveInterval(-1);
    //nastaveni stalych promenych do session
    session.setAttribute("backURL", "tattendance.jsp");
    //pripojeni k databazi
    Connection conn = dbPool.getDBConn();
    PreparedStatement pstmt, pstmtpom = null;
    ResultSet resultSet, resultSetPom = null;
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <link rel=StyleSheet href="css/default.css" type="text/css"/>
        <title>BT - Prezence hráčů</title>
        <style type="text/css">
            table
            {
                border-collapse:collapse;
            }
            table, td, th
            {
                border:0px solid black;
                padding: 0px 5px 0px 10px;
                text-align: center;
            }
            th
            {
                background-color:black;
                color:white;
            }
        </style>
        <SCRIPT LANGUAGE="JavaScript">
            function add2list(sourceID, targetID) {
                source = document.getElementById(sourceID);
                target = document.getElementById(targetID);
                numberOfItems = source.options.length;
                insertPt = target.options.length; // insert at end
                if (target.options[0].text === "") {
                    insertPt = 0;
                } // null option fix
                for (i = 0; i < numberOfItems; i++) {
                    //oznacene polozky ve zdrojovem formulari
                    if (source.options[i].selected === true) {
                        val = source.options[i].value;
                        msg = source.options[i].text;
                        target.options[insertPt] = new Option(msg, val, false, false);
                        insertPt = target.options.length;
                    }
                }
                takefromlist(sourceID);
            }
            function takefromlist(targetID) {
                target = document.getElementById(targetID);
                if (target.options.length < 0) {
                    return;
                }
                for (var i = (target.options.length - 1); i >= 0; i--) {
                    if (target.options[i].selected) {
                        target.options[i] = null;
                        if (target.options.length === 0) {
                            target.options[0] = new Option("");
                        }
                    }
                }
            }

            function selectAll(targetID) {
                target = document.getElementById(targetID);
                ;
                len = target.options.length;
                for (var i = (len - 1); i >= 0; i--) {
                    target.options[i].selected = true;
                }
                return true;
            }
        </SCRIPT>

    </head>
    <body <%= request.getParameter("dbop") != null ? " onload=\"parent.frames['tleft'].location.reload();\"" : ""%>>
        <div id="msg"><%= session.getAttribute("s_msg") != null ? session.getAttribute("s_msg") : ""%></div>
        <%session.removeAttribute("s_msg");%>

        <form method="post" action="Tattendance" onsubmit="return selectAll('list2')">
            <table style="margin-top:10px;">
                <tr><th>Databáze hráčů</th><td>&nbsp;</td><th>Zapsat do turnaje</th></tr>
                <tr>
                    <td valign="top">
                        <select id="list1" multiple="multiple" ondblclick="add2list('list1', 'list2');" style="width:220px;height: 500px;">
                            <%
                                pstmt = conn.prepareStatement("SELECT player.pid,psurname,pname FROM player WHERE player.pid NOT IN (SELECT tpresentation.pid FROM tpresentation WHERE trid=?) ORDER BY psurname,pname");
                                pstmt.setInt(1, (Integer) session.getAttribute("trID"));
                                resultSet = pstmt.executeQuery();

                                while (resultSet.next()) {

                                    out.println("<option value='" + resultSet.getString("pid") + "'>" + resultSet.getString("psurname") + " " + resultSet.getString("pname") + "</option>");
                                }
                            %>
                        </select>
                    </td>

                    <td>

                        <button onclick="add2list('list1', 'list2');
                                return false;"> --&gt; </button>
                        <button onclick="add2list('list2', 'list1');
                                return false;"> &lt;-- </button>
                        <br/><br/>
                        <input type="submit" value="Uložit"/>
                    </td>
                    <td style="width:220px;height:350px;" valign="top">
                        <select id="list2" multiple="multiple" name="pit" ondblclick="add2list('list2', 'list1');" style="width:220px;height: 140px;">
                            <option></option>
                        </select>
                        //SELECT DISTINCT EXTRACT(YEAR FROM tround.tdate) FROM tround WHERE tend='Y';
                        <br/>
                        <!--<select id="list3" multiple="multiple" disabled="disabled" style="width:220px;height:350px;">-->
                        <table>
                            <%
                                pstmt = conn.prepareStatement("SELECT player.pid,player.psurname,player.pname,hc FROM player,tpresentation WHERE trid=? AND tpresentation.pid=player.pid ORDER BY psurname,pname");
                                pstmt.setInt(1, (Integer) session.getAttribute("trID"));
                                resultSet = pstmt.executeQuery();

                                while (resultSet.next()) {
                                    //out.println("<option value='" + resultSet.getString("pid") + "'>" + resultSet.getString("psurname") + " " + resultSet.getString("pname") + "</option>");
                                    //pokud nema hrac odehrany v turnajovem kole - povolime odstraneni ze seznamu
                                    pstmtpom = conn.prepareStatement("SELECT count(*) AS pz FROM tscore WHERE trid=? AND pid=?");
                                    pstmtpom.setInt(1, (Integer) session.getAttribute("trID"));
                                    pstmtpom.setInt(2, resultSet.getInt("pid"));
                                    resultSetPom = pstmtpom.executeQuery();
                                    resultSetPom.next();

                                    out.println("<tr><td style='text-align: left;'>" + resultSet.getString("psurname") + " " + resultSet.getString("pname") + "</td><td style='text-align: right;'>(" + resultSet.getString("hc") + ")</td><td>" + (resultSetPom.getInt("pz") == 0 ? "<a href='Tattendance?tpid=" + resultSet.getString("pid") + "'>[-]</a>" : "") + "</td></tr>");
                                }
                            %>
                        </table>
                        <!--</select>-->
                    </td>
                </tr>
            </table>
        </form>
    </body>
</html>
<%
    resultSet.close();
    pstmt.close();
    conn.close();
%>
