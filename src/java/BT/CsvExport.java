/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package BT;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

import java.sql.*;
import VtGUtils.*;

/**
 *
 * @author VtG
 */
public class CsvExport extends HttpServlet {

    DbPool dbPool = null;

    @Override
    public void init() throws ServletException {
        dbPool = new DbPool("java:comp/env/jdbc/PGpoolBT");
    }

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/octet-stream");
        response.setHeader("Content-Disposition", "attachment; filename=\"cba-export.csv\"");

        HttpSession session = request.getSession(true);

        String msg = null;
        String sqlQuery = null;

        if (session.getAttribute("tType").equals("C")) {
            /*
            sqlQuery =
            "SELECT DISTINCT "
            + "tscore.tstep as tstep,"
            + "tscore.tround as tround,"
            + "tscore.tstart as tstart,"
            + "player.pid as pid,"
            + "player.psurname as psurname,"
            + "player.pname as pname,"
            + "getplayerscorecsv(tscore.pid,tscore.trid,1) as qualif_score,"
            + "getplayersum(tscore.pid,tscore.trid,1) as qualif_total,"
            + "getplayersumtotal(tscore.pid,tscore.trid,1) as qualif_total_hc,"
            + "getplayerscorecsv(tscore.pid,tscore.trid,2) as final_score,"
            + "getplayersum(tscore.pid,tscore.trid,2) as final_total,"
            + "getplayertotalavg(tscore.pid,tscore.trid) as total_avg,"
            + "getplayersumtotal(tscore.pid,tscore.trid,2) as final_total_hc,"
            + "getplayermaxstepscr(tscore.pid,tscore.trid,1) as kmax,"
            + "getplayermaxstepscr(tscore.pid,tscore.trid,2) as fmax,"
            + "getplayerpomscr(tscore.pid,tscore.trid,1,tscore.tstart) as kpomscr,"
            + "getplayerpomscr(tscore.pid,tscore.trid,2,tscore.tstart) as fpomscr,"
            + "tscore.tcount as tcount, "
            + "tpresentation.hc as hc "
            + "FROM tscore,player,tpresentation "
            + "WHERE tscore.trid=? AND tscore.tstep=1 AND tscore.tcount='Y' AND player.pid=tscore.pid AND player.pid=tpresentation.pid "
            + "GROUP BY tscore.tstep,tscore.trid, tscore.pid, tscore.tround, tscore.tstart, tscore.tcount, player.pid, player.psurname, player.pname, tpresentation.hc "
            + "ORDER BY tstep DESC, final_total_hc DESC NULLS LAST, final_total DESC NULLS LAST, fmax DESC, fpomscr DESC, qualif_total_hc DESC, qualif_total DESC, fmax DESC, fpomscr DESC";
             */
            sqlQuery = Tfinish.sqlQueryC;
        } else if (session.getAttribute("tType").equals("B")) {

            /*
            sqlQuery = "SELECT DISTINCT "
            + "tscore.tstep as tstep,"
            + "tscore.tround as tround,"
            + "tscore.tstart as tstart,"
            + "player.pid as pid,"
            + "player.psurname as psurname,"
            + "player.pname as pname,"
            + "tpresentation.hc as hc,"
            + "getplayerscorecsv(tscore.pid,tscore.trid,1) as qualif_score,"
            + "getplayersum(tscore.pid,tscore.trid,1) as qualif_total,"
            + "getplayersumtotal(tscore.pid,tscore.trid,1) as qualif_total_hc,"
            + "getplayertotalavgr(tscore.pid,tscore.trid,1,tscore.tstart) as qualif_avg,"
            + "getplayerscorecsv(tscore.pid,tscore.trid,2) as final_score,"
            + "getplayersum(tscore.pid,tscore.trid,2) as final_total,"
            + "getplayersumtotal(tscore.pid,tscore.trid,2) as final_total_hc,"
            + "getplayertotalavg(tscore.pid,tscore.trid) as total_avg,"
            + "(getplayertotalavgr(tscore.pid,tscore.trid,1,tscore.tstart) + getplayersum(tscore.pid,tscore.trid,2)) as tournament_total,"
            + "(getplayertotalavgr(tscore.pid,tscore.trid,1,tscore.tstart) + getplayersumtotal(tscore.pid,tscore.trid,2)) as tournament_total_hc,"
            + "getplayermaxstepscr(tscore.pid,tscore.trid,1) as kmax,"
            + "getplayermaxstepscr(tscore.pid,tscore.trid,2) as fmax,"
            + "getplayerpomscr(tscore.pid,tscore.trid,1,tscore.tstart) as kpomscr,"
            + "getplayerpomscr(tscore.pid,tscore.trid,2,tscore.tstart) as fpomscr,"
            + "tscore.tcount as tcount "
            + "FROM tscore,player,tpresentation "
            + "WHERE tscore.trid=? AND tscore.tstep=1 AND tscore.tcount='Y' AND player.pid=tscore.pid AND player.pid=tpresentation.pid "
            + "GROUP BY tscore.tstep,tscore.trid, tscore.pid, tscore.tround, tscore.tstart, tscore.tcount, player.pid, player.psurname, player.pname, tpresentation.hc "
            + "ORDER BY tstep DESC, tournament_total_hc DESC NULLS LAST, tournament_total DESC NULLS LAST, fmax DESC, fpomscr DESC, qualif_total_hc DESC, qualif_total DESC, kmax DESC, kpomscr DESC";
             */
            sqlQuery = Tfinish.sqlQueryB;
        } else {
            sqlQuery = Tfinish.sqlQueryA;
        }

        String sqlQueryr =
                "SELECT "
                + "player.psurname as psurname,"
                + "player.pname as pname,"
                + "getplayerscorecsvr(tscore.pid,tscore.trid,1,tstart) as qualif_score "
                + "FROM tscore,player "
                + "WHERE tscore.trid=? AND tscore.tstep=1 AND tscore.tcount='N' AND player.pid=tscore.pid "
                + "GROUP BY tscore.trid, tscore.pid, tscore.tstart, tscore.tcount, player.psurname, player.pname "
                + "ORDER BY psurname, pname";


        if (dbPool.isInitErr()) {

            msg = "<h2>CSV Export - DB pool exception:</h2>" + dbPool.getInitErrTxt();

        } else { //zpracujeme data o novem formulari

            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet resultSet = null;

            //jsou-li vyplnene vsechny povinne udaje provedeme zapis do databaze
            if (msg == null) {

                try {

                    conn = dbPool.getDBConn();

                    //nejdrive zapiseme celkove vysledky
                    pstmt = conn.prepareStatement(sqlQuery);
                    pstmt.setInt(1, (Integer) session.getAttribute("trID"));
                    resultSet = pstmt.executeQuery();

                    OutputStream o = response.getOutputStream();
                    StringBuffer line = new StringBuffer();

                    while (resultSet.next()) {
                        line.append("\"" + resultSet.getString("psurname") + " " + resultSet.getString("pname") + "\";");
                        line.append(resultSet.getString("qualif_score_csv") + ";");
                        line.append(resultSet.getString("final_score_csv") == null ? " " : resultSet.getString("final_score_csv"));
                        line.append("\n");
                    }

                    //prazdna radka
                    line.append("\n");

                    //restartty
                    pstmt = conn.prepareStatement(sqlQueryr);
                    pstmt.setInt(1, (Integer) session.getAttribute("trID"));
                    resultSet = pstmt.executeQuery();

                    while (resultSet.next()) {
                        line.append("\"" + resultSet.getString("psurname") + " " + resultSet.getString("pname") + "\";");
                        line.append(resultSet.getString("qualif_score") + ";");
                        line.append("\n");
                    }

                    o.write(line.toString().getBytes());
                    o.flush();

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
        return "Short description";
    }// </editor-fold>
}
