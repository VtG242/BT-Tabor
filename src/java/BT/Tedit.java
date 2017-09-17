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
public class Tedit extends HttpServlet {

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

        //promene pro cely request
        int pid = Integer.valueOf(request.getParameter("pid"));

        //nastavime spravne kodovani
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {

            out.println("<html>");
            out.println("<head>");
            out.println("<title>BT - editace výsledků</title>");
            out.println("<link rel='StyleSheet' href='css/default.css' type='text/css'>");
            out.println("</head>");
            out.println("<body>");

            out.println("<div id='msg'>" + (session.getAttribute("s_msg") != null ? session.getAttribute("s_msg") : "") + "</div>");
            session.removeAttribute("s_msg");

            //z databaze ziskame udaje o vsech hrach hrace
            if (dbPool.isInitErr()) {

                out.println("<h2>Přidat score - DB pool exception:</h2>" + dbPool.getInitErrTxt());

            } else { //zpracujeme data pro editacni formulare

                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet resultSet = null;

                try {

                    conn = dbPool.getDBConn();

                    //zapiseme resp. zmenime data z formulare do databaze
                    pstmt = conn.prepareStatement("SELECT psurname,pname,tstart,tstep,tround,gscore,hc,gpomscr,tcount,tscore.oid FROM tscore,player WHERE tscore.pid=? AND trid=? AND tscore.pid=player.pid ORDER BY oid,tstep,tstart");
                    pstmt.setInt(1, pid);
                    pstmt.setInt(2, (Integer) session.getAttribute("trID"));

                    resultSet = pstmt.executeQuery();

                    out.println("<table border=0 style='margin-top:10px;font-family: Tahoma, Helvetica, serif; font-size: 10pt;'>");
                    out.println("<tr><th>&nbsp;</th><th>krok</th><th>start</th><th>runda</th><th>score</th><th>HC</th><th>pomscr</th><th>započteno</th><th>&nbsp;</th></tr>");

                    while (resultSet.next()) {

                        out.println("<form action='Tedit' method='post'><tr><td>" + resultSet.getString("psurname") + " " + resultSet.getString("pname") + "</td>" +
                                "<td>" +
                                "<select name='tstep'>" +
                                "<option value='1'" + (resultSet.getInt("tstep") == 1 ? "selected" : "") + ">1 - kvalifikace</option> " +
                                "<option value='2'" + (resultSet.getInt("tstep") == 2 ? "selected" : "") + ">2 - finále</option> " +
                                "</select>" +
                                "</td>" +
                                "<td>" +
                                "<select name='tstart'>" +

                                "<option value='1'" + (resultSet.getInt("tstart") == 1 ? "selected" : "") + ">1.</option> " +
                                "<option value='2'" + (resultSet.getInt("tstart") == 2 ? "selected" : "") + ">2.</option> " +
                                "<option value='3'" + (resultSet.getInt("tstart") == 3 ? "selected" : "") + ">3.</option> " +
                                "</select>" +
                                "</td>" +
                                "<td>" +
                                "<select name='tround'>" +
                                "<option value='0'" + (resultSet.getInt("tround") == 1 ? "selected" : "") + ">0.</option> " +
                                "<option value='1'" + (resultSet.getInt("tround") == 1 ? "selected" : "") + ">1.</option> " +
                                "<option value='2'" + (resultSet.getInt("tround") == 2 ? "selected" : "") + ">2.</option> " +
                                "<option value='3'" + (resultSet.getInt("tround") == 3 ? "selected" : "") + ">3.</option> " +
                                "<option value='4'" + (resultSet.getInt("tround") == 4 ? "selected" : "") + ">4.</option> " +
                                "</select>" +
                                "</td>" +
                                "<td><input size='3' type='text' name='tscore' value='" +
                                resultSet.getInt("gscore") +
                                "'></td>" +
                                "<td><input size='2' type='text' name='hc' value='" +
                                resultSet.getInt("hc") +
                                "'></td>" +
                                "<td><input size='2' type='text' name='gpomscr' value='" +
                                resultSet.getInt("gpomscr") +
                                "'></td>" +
                                "<td>" +
                                "<select name='tcount'>" +
                                "<option value='Y'" + (resultSet.getString("tcount").equals("Y") ? "selected" : "") + ">ANO</option> " +
                                "<option value='N'" + (resultSet.getString("tcount").equals("N") ? "selected" : "") + ">NE</option> " +
                                "</select>" +
                                "</td>" +
                                "<td>" +
                                "<input type='submit' value='uložit změnu'>" +
                                "<input type='hidden' name='tscrrec' value='" + resultSet.getString("oid") + "'>" +
                                "<input type='hidden' name='pid' value='" + pid + "'>" +
                                "</td>" +
                                "<td><a href='DelScore?oid=" + resultSet.getString("oid") + "'>[ smazat ]</a></td>" +
                                "</tr></form>");

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
        int tStep = 0;
        int tRound = 0;
        int tStart = 0;
        int tScore = 0;
        int hc = 0;
        int gpomscr = 0;
        int tscrrec = 0;
        String tcount = "Y";
        String msg = null;
        String backPage = "Tedit?pid=" + pid;

        //nastavime spravne kodovani
        request.setCharacterEncoding("UTF-8");

        if (dbPool.isInitErr()) {

            msg = "<h2>Přidat score - DB pool exception:</h2>" + dbPool.getInitErrTxt();

        } else { //zpracujeme data o novem formulari

            Connection conn = null;
            PreparedStatement pstmt = null;

            //provedeme kontrolu povinnych udaju a ziskame data z formulare
            if (AddScore.isValidScore(request.getParameter("tscore"))) {
                tStep = Integer.valueOf(request.getParameter("tstep"));
                tStart = Integer.valueOf(request.getParameter("tstart"));
                tRound = Integer.valueOf(request.getParameter("tround"));
                tScore = Integer.valueOf(request.getParameter("tscore"));
                hc = Integer.valueOf(request.getParameter("hc"));
                gpomscr = Integer.valueOf(request.getParameter("gpomscr"));
                tscrrec = Integer.valueOf(request.getParameter("tscrrec"));
                tcount = request.getParameter("tcount");
                //DEBUG
                //msg = "Hrac:" + pid + " HC:" + hc + " step:" + tStep + " runda:" + tRound + " start:" + tStart + " score:" + tScore + " gpomscr:" + gpomscr + " OID:" + tscrrec + " tcount:" + tcount;
            } else {
                msg = "Neplatné score!";
            }

            //jsou-li vyplnene vsechny povinne udaje provedeme zapis do databaze
            if (msg == null) {

                try {

                    conn = dbPool.getDBConn();

                    //zapiseme resp. zmenime data z formulare do databaze
                    pstmt = conn.prepareStatement("UPDATE tscore SET tstep=?,tstart=?,hc=?,gscore=?,tround=?,gpomscr=?,tcount=? WHERE trid=? AND pid=? AND oid=?");
                    pstmt.setInt(1, tStep);
                    pstmt.setInt(2, tStart);
                    pstmt.setInt(3, hc);
                    pstmt.setInt(4, tScore);
                    pstmt.setInt(5, tRound);
                    pstmt.setInt(6, gpomscr);
                    pstmt.setString(7, tcount);
                    pstmt.setInt(8, (Integer) session.getAttribute("trID"));
                    pstmt.setInt(9, pid);
                    pstmt.setInt(10, tscrrec);

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


