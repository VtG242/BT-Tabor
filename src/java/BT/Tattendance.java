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
public class Tattendance extends HttpServlet {

    DbPool dbPool = null;

    @Override
    public void init() throws ServletException {
        dbPool = new DbPool("java:comp/env/jdbc/PgBTTabor");
    }

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

        HttpSession session = request.getSession(true);

        //promene pro cely request
        String msg = null;
        String backPage = (String) session.getAttribute("backURL");

        //nastavime spravne kodovani
        request.setCharacterEncoding("UTF-8");

        if (dbPool.isInitErr()) {

            msg = "<h2>Prezentace hráčů - DB pool exception:</h2>" + dbPool.getInitErrTxt();

        } else { //zpracujeme data o novem formulari

            Connection conn = null;
            PreparedStatement pstmt = null;

            //jsou-li vyplnene vsechny povinne udaje provedeme zapis do databaze
            if (request.getParameter("tpid") == null) {
                msg = "Neplatné ID hráče!";
            }
            if (msg == null) {

                try {

                    conn = dbPool.getDBConn();
                    pstmt = conn.prepareStatement("DELETE from tpresentation WHERE trid=? AND pid=?");
                    pstmt.setInt(1, (Integer) session.getAttribute("trID"));
                    pstmt.setInt(2, Integer.parseInt(request.getParameter("tpid")));
                    pstmt.executeUpdate();
                    pstmt.close();
                    conn.close();
                    backPage += "?dbop=true";

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
        String msg = null;
        String backPage = (String) session.getAttribute("backURL");

        //nastavime spravne kodovani
        request.setCharacterEncoding("UTF-8");

        if (dbPool.isInitErr()) {

            msg = "<h2>Prezentace hráčů - DB pool exception:</h2>" + dbPool.getInitErrTxt();

        } else { //zpracujeme data o novem formulari

            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            String[] pit = null;
            int hcz, hcv = 0;
            double avg = 0.00;
            int hc = 0;

            //jsou-li vyplnene vsechny povinne udaje provedeme zapis do databaze
            if (request.getParameterValues("pit") == null) {
                msg = "Seznam hráču k zapsání do turnaje je prázdný!";
            } else {
                pit = request.getParameterValues("pit");
            }

            if (msg == null) {

                try {

                    conn = dbPool.getDBConn();
                    for (int loopIndex = 0; loopIndex < pit.length; loopIndex++) {
                        //je-li ucastnikem turnaje zena rovnou zapiseme startovaci HC
                        pstmt = conn.prepareStatement("SELECT "
                                + "pid, pgender, "
                                + "getplayerseasonavg(2012,pid) AS avg, "
                                + "getplayerseasonhc(2012,pid) AS hc "
                                + "FROM player "
                                + "WHERE pid=?");

                        pstmt.setInt(1, Integer.parseInt(pit[loopIndex]));
                        rs = pstmt.executeQuery();

                        rs.next();

                        avg = rs.getDouble("avg");
                        if (rs.getString("pgender").equals("F")) {
                            if (avg >= 180) {
                                hcz = 4;
                            } else {
                                hcz = 8;
                            }
                        } else {
                            hcz = 0;
                        }
                        if (rs.getInt("hc") >= 0) {
                            hcv = rs.getInt("hc");
                        } else {
                            hcv = 0;
                        }

                        //hrajeme-li devitku je pocitan pouze zakladni HC
                        if (session.getAttribute("tType").equals("C")) {
                            hc = hcz;
                        } else {
                            hc = hcz + hcv;
                        }

                        pstmt = conn.prepareStatement("INSERT INTO tpresentation (trid,pid,hc) VALUES (?,?,?)");
                        pstmt.setInt(1, (Integer) session.getAttribute("trID"));
                        pstmt.setInt(2, Integer.parseInt(pit[loopIndex]));
                        pstmt.setInt(3, hc);
                        pstmt.executeUpdate();
                    }
                    pstmt.close();
                    conn.close();
                    backPage += "?dbop=true";

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

    @Override
    public String getServletInfo() {
        return "Servlet pro spravu hráčů v turnaji.";
    }
}
