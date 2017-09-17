/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package BT;

import javax.servlet.*;
import javax.servlet.http.*;

import java.io.*;
import java.sql.*;
import VtGUtils.*;

/**
 *
 * @author VtG
 */
public class Tcount extends HttpServlet {

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
        String backPage = (String) session.getAttribute("backURL");
        String tCountState = "Y";
        int pid = 0;
        int tStart = 0;

        //nastavime spravne kodovani
        request.setCharacterEncoding("UTF-8");

        if (dbPool.isInitErr()) {

            msg = "<h2>Upravení stavu hry - tcount - DB pool exception:</h2>" + dbPool.getInitErrTxt();

        } else { //zpracujeme data o novem formulari

            Connection conn = null;
            PreparedStatement pstmt = null;

            //formularova data
            pid = Integer.valueOf(request.getParameter("pid"));
            tStart = Integer.valueOf(request.getParameter("start"));
            tCountState = request.getParameter("state");

            //jsou-li vyplnene vsechny povinne udaje provedeme zapis do databaze
            if (msg == null) {

                try {

                    conn = dbPool.getDBConn();

                    //zapiseme resp. zmenime data z formulare do databaze
                    pstmt = conn.prepareStatement("UPDATE tscore SET tcount=? WHERE trid=? AND pid=? AND tstart=?");
                    pstmt.setString(1, tCountState);
                    pstmt.setInt(2, (Integer) session.getAttribute("trID"));
                    pstmt.setInt(3, pid);
                    pstmt.setInt(4, tStart);

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

