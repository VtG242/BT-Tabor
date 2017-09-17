/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package BT;

import javax.servlet.*;
import javax.servlet.http.*;

import java.io.*;
import java.sql.*;
import java.util.regex.*;
import VtGUtils.*;

/**
 *
 * @author VtG
 */
public class AddScore extends HttpServlet {

    DbPool dbPool = null;

    @Override
    public void init() throws ServletException {
        dbPool = new DbPool("java:comp/env/jdbc/PGpoolBT");
    }

    /** Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
     * @param request servlet request
     * @param response servlet response
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(true);

        //promene pro cely request
        String msg = null;
        String[] PlayerHC = null;
        String backPage = null;
        int tStep = 0;
        int tRound = 0;
        int tStart = 0;
        int tScore = 0;

        //nastavime spravne kodovani
        request.setCharacterEncoding("UTF-8");

        if (dbPool.isInitErr()) {

            msg = "<h2>Přidat score - DB pool exception:</h2>" + dbPool.getInitErrTxt();

        } else { //zpracujeme data o novem formulari

            Connection conn = null;
            PreparedStatement pstmt = null;

            //provedeme kontrolu povinnych udaju a ziskame data z formulare
            if (isValidScore(request.getParameter("tscore"))) {
                tScore = Integer.valueOf(request.getParameter("tscore"));
                PlayerHC = Pattern.compile("_").split(request.getParameter("player"));
                tStep = Integer.valueOf(request.getParameter("tstep"));
                tRound = Integer.valueOf(request.getParameter("tround"));
                tStart = Integer.valueOf(request.getParameter("tstart"));
                backPage = tStep==1 ? "tStepResults.jsp?step=1&sort=7":"tStepResults.jsp?step=2&sort=7";
                session.setAttribute("backURL", backPage);

            //DEBUG
            //msg = "Hrac:" + PlayerHC[0] + " HC:" + PlayerHC[1] + " step:" + tStep + " runda:" + tRound + " start:" + tStart + " score:" + tScore;
            } else {
                msg = "Neplatné score!";
            }

            //jsou-li vyplnene vsechny povinne udaje provedeme zapis do databaze
            if (msg == null) {

                try {

                    conn = dbPool.getDBConn();

                    //zapiseme resp. zmenime data z formulare do databaze
                    pstmt = conn.prepareStatement("INSERT INTO tscore (trid,pid,tstep,tstart,hc,gscore,tround) VALUES (?,?,?,?,?,?,?)");
                    pstmt.setInt(1, (Integer) session.getAttribute("trID"));
                    pstmt.setInt(2, Integer.parseInt(PlayerHC[0]));
                    pstmt.setInt(3, tStep);
                    pstmt.setInt(4, tStart);
                    pstmt.setInt(5, Integer.parseInt(PlayerHC[1]));
                    pstmt.setInt(6, tScore);
                    pstmt.setInt(7, tRound);

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
            //prasecina
            //response.sendRedirect(response.encodeRedirectURL("http://localhost:8084/BT/tStepResults.jsp?step=2&sort=7"));

        }

    }

    protected static boolean isValidScore(String testVariable) {
        int p = 0;
        try {
            p = Integer.parseInt(testVariable);
            return (p > 0 && p <= 300) ? true : false;

        } catch (NumberFormatException e) {
            return false;
        }
    }


// <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
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
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Servlet pro pridavani vysledku hrace po odehrani hry.";
    }
// </editor-fold>
}

