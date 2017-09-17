<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="VtGUtils.*"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*" %>
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
            int year = java.util.Calendar.getInstance().get(Calendar.YEAR);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <link rel=StyleSheet href="css/default.css" type="text/css"/>
        <title>BT - Body - Výběr ročníku</title>
        <base target="tright"/>
        <SCRIPT LANGUAGE="JavaScript" type="text/javascript">
            function go(form)
            {
                x=form.year.selectedIndex;
                skript="tpoints.jsp?year="+form.year[x].value;
                window.open(skript,'tright');
            }
        </SCRIPT>
    </head>
    <body>
        <fieldset style="font-weight: bolder;" class="trunning">
            <legend>Celkové pořadí</legend>
            <form>
                <table>
                    <tbody>
                        <tr>
                            <td>
                                <select name="year" onChange="go(this.form)" size="1" style="width: 184px">
                                    <option value="<%=year%>"> -- ročník --</option>
                                    <%
                                                try {

                                                    pstmt = conn.prepareStatement("SELECT DISTINCT EXTRACT(YEAR FROM tdate) as tyear FROM tround ORDER BY tyear");

                                                    resultSet = pstmt.executeQuery();

                                                    while (resultSet.next()) {
                                                        out.println("<option value=" + resultSet.getInt("tyear") + ">&nbsp;" + resultSet.getInt("tyear") + "&nbsp;</option>");
                                                    }

                                                } catch (SQLException e) {
                                                    if (session.getAttribute("s_msg") == null) {
                                                        session.setAttribute("s_msg", "Chyba SQL: " + e.getMessage());
                                                    } else {
                                                        session.setAttribute("s_msg", (session.getAttribute("s_msg") + "<br/>Chyba SQL: " + e.getMessage()));
                                                    }
                                                }
                                    %>
                                </select>

                            </td>
                        </tr>

                    </tbody>
                    <tfoot>
                        <tr><td colspan="4"><span style="color: red"><%= session.getAttribute("s_msg") != null ? session.getAttribute("s_msg") + "<br/>" : ""%></span><%session.removeAttribute("s_msg");%></td></tr>
                    </tfoot>
                </table>

            </form>
        </fieldset>
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
