/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package BT;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import VtGUtils.*;
import java.sql.*;

/**
 *
 * @author VtG
 */
public class AddPlayer extends HttpServlet {

    DbPool dbPool = null;

    @Override
    public void init() throws ServletException {
        dbPool = new DbPool("java:comp/env/jdbc/PgBTTabor");
    }

    /**
     * Handles the HTTP
     * <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
    }

    /**
     * Handles the HTTP
     * <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        //nastavime spravne kodovani
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(true);
        //PrintWriter out = response.getWriter();

        //promene pro cely request
        String msg = null;
        boolean eMsg = false;

        if (dbPool.isInitErr()) {

            msg = "<h3>Přidat hráče - DB pool exception:</h3>" + dbPool.getInitErrTxt();
            eMsg = true;

        } else { //zpracujeme data o novem formulari

            Connection conn = null;
            PreparedStatement pstmt = null;

            //provedeme kontrolu povinnych udaju a ziskame data z formulare
            if (request.getParameter("name").equals("") || request.getParameter("surname").equals("")) {
                msg = "Jméno a příjmení musí být zadáno !";
                eMsg = true;
            }

            //jsou-li vyplnene vsechny povinne udaje provedeme zapis do databaze
            if (msg == null) {

                try {

                    conn = dbPool.getDBConn();

                    //zacneme db transakci
                    conn.setAutoCommit(false);
                    //nyni zapiseme nove hodnoty do matches
                    pstmt = conn.prepareStatement("INSERT INTO player(pname,psurname,pgender) VALUES (?,?,?)");
                    pstmt.setString(1, request.getParameter("name"));
                    pstmt.setString(2, request.getParameter("surname"));
                    pstmt.setString(3, request.getParameter("sex"));
                    pstmt.executeUpdate();
                    pstmt.close();

                    //ukoncime transakci
                    conn.commit();

                    //zapis turnaje uspesne vlozen do dtb
                    msg = "Hráč přidán úspěšně !";
                    eMsg = false;
                    
                    //uzavreme spojeni
                    conn.close();

                } catch (SQLException e) {

                    msg = "Chyba SQL:<br/>" + e.getMessage();
                    eMsg = true;

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

        }
        //presmerovani na stranku kde probehne info o probehlem pozadavku
        session.setAttribute("s_msg", msg);
        session.setAttribute("s_emsg", eMsg);
        response.sendRedirect(response.encodeRedirectURL("index.jsp"));
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Přidání turnaje.";
    }
}
