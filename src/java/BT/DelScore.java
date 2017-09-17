/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package BT;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.*;
import javax.servlet.http.*;

import java.sql.*;
import VtGUtils.*;

/**
 *
 * @author VtG
 */
public class DelScore extends HttpServlet {

    DbPool dbPool = null;

    @Override
    public void init() throws ServletException {
        dbPool = new DbPool("java:comp/env/jdbc/PGpoolBT");
    }

    /**
     * Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        HttpSession session = request.getSession(true);

        //nastavime spravne kodovani
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {

            out.println("<html>");
            out.println("<head>");
            out.println("<title>BT - odstranění výsledku</title>");
            out.println("<link rel='StyleSheet' href='css/default.css' type='text/css'>");
            out.println("</head>");
            out.println("<body>");

            out.println("<div id='msg'>" + (session.getAttribute("s_msg") != null ? session.getAttribute("s_msg") : "") + "</div>");
            session.removeAttribute("s_msg");

            //z databaze ziskame udaje o vsech hrach hrace
            if (dbPool.isInitErr()) {

                out.println("<h2>Výmaz score - DB pool exception:</h2>" + dbPool.getInitErrTxt());

            } else { //zpracujeme data pro editacni formulare

                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet resultSet = null;

                try {

                    conn = dbPool.getDBConn();

                    //zapiseme resp. zmenime data z formulare do databaze
                    pstmt = conn.prepareStatement("SELECT tscore.pid as pid,psurname,pname,tstart,tstep,tround,gscore,hc,gpomscr,tcount FROM tscore,player WHERE oid=? AND tscore.pid=player.pid");
                    pstmt.setInt(1, Integer.valueOf(request.getParameter("oid")));

                    resultSet = pstmt.executeQuery();

                    out.println("<table align='left' border='1' style='margin-top:10px;font-family: Tahoma, Helvetica, serif; font-size: 10pt;'>");
                    out.println("<tr><td colspan='8' align='center'><strong>Opravdu smazat tento záznam?</strong></td></tr>");
                    out.println("<tr><th>&nbsp;</th><th>krok</th><th>start</th><th>runda</th><th>score</th><th>HC</th><th>pomscr</th><th>započteno</th></tr>");

                    while (resultSet.next()) {

                        out.println("<form action='DelScore' method='post'>" +
                                "<tr><td>" + resultSet.getString("psurname") + " " + resultSet.getString("pname") + "</td>" +
                                "<td>" +
                                (resultSet.getInt("tstep") == 1 ? "1 - kvalifikace" : "2 - finále") +
                                "</td>" +
                                "<td>" +
                                resultSet.getInt("tstart") +
                                "</td>" +
                                "<td>" +
                                resultSet.getInt("tround") +
                                "</td>" +
                                "<td>" +
                                resultSet.getInt("gscore") +
                                "</td>" +
                                "<td>" +
                                resultSet.getInt("hc") +
                                "</td>" +
                                "<td>" +
                                resultSet.getInt("gpomscr") +
                                "</td>" +
                                "<td>" +
                                (resultSet.getString("tcount").equals("Y") ? "ANO" : "NE") +
                                "</td>" +
                                "</tr>" +
                                "<tr><td colspan='8' align='center'>" +
                                "<input type='submit' value='ANO'>" +
                                "<input type='hidden' name='tscrrec' value='" + request.getParameter("oid") + "'>" +
                                "<input type='hidden' name='pid' value='" + resultSet.getString("pid") + "'>" +
                                "</td><tr>" +
                                "</form>");

                    }

                    out.println("</table>");

                    pstmt.close();

                    conn.close();


                } catch (SQLException e) {

                    out.println("Chyba SQL:" + e.getMessage());

                } finally {

                    if (pstmt != null) {
                        try {
                            pstmt.close();
                        } catch (SQLException sqlex) {
                            // ignore -- as we can't do anything about it here
                            }
                        pstmt = null;
                    }
                    if (conn != null) {
                        try {
                            conn.close();
                        } catch (SQLException sqlex) {
                            // ignore -- as we can't do anything about it here
                            }
                        conn = null;
                    }

                }

                out.println("</body>");
                out.println("</html>");
            }

        } finally {
            out.close();
        }

    }

    /**
     * Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(true);

        //promene pro cely request
        int pid = Integer.valueOf(request.getParameter("pid"));
        int tscrrec = Integer.valueOf(request.getParameter("tscrrec"));
        String msg = null;
        String backPage = "Tedit?pid=" + pid;

        //nastavime spravne kodovani
        request.setCharacterEncoding("UTF-8");

        if (dbPool.isInitErr()) {

            msg = "<h2>Výmaz zaznamu - DB pool exception:</h2>" + dbPool.getInitErrTxt();

        } else { //zpracujeme data o novem formulari

            Connection conn = null;
            PreparedStatement pstmt = null;

            //jsou-li vyplnene vsechny povinne udaje provedeme zapis do databaze
            if (msg == null) {

                try {

                    conn = dbPool.getDBConn();

                    //zapiseme resp. zmenime data z formulare do databaze
                    pstmt = conn.prepareStatement("DELETE FROM tscore WHERE trid=? AND pid=? AND oid=?");
                    pstmt.setInt(1, (Integer) session.getAttribute("trID"));
                    pstmt.setInt(2, pid);
                    pstmt.setInt(3, tscrrec);

                    pstmt.executeUpdate();

                    pstmt.close();

                    conn.close();


                } catch (SQLException e) {

                    msg = "Chyba SQL:" + e.getMessage();

                } finally {

                    if (pstmt != null) {
                        try {
                            pstmt.close();
                        } catch (SQLException sqlex) {
                            // ignore -- as we can't do anything about it here
                        }
                        pstmt = null;
                    }
                    if (conn != null) {
                        try {
                            conn.close();
                        } catch (SQLException sqlex) {
                            // ignore -- as we can't do anything about it here
                        }
                        conn = null;
                    }

                }

            }

            //presmerovani na stranku kde probehne info o probehlem pozadavku
            session.setAttribute("s_msg", msg);
            response.sendRedirect(response.encodeRedirectURL(backPage));
        }

    }
}
