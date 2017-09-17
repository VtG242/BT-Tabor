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
public class Tfinish extends HttpServlet {

    //promene pro cely servlet
    DbPool dbPool = null;
    //SQL dotazy
    public static final String sqlQueryC = "SELECT "
            + "tscore.tstep as tstep,"
            + "tscore.tround as tround,"
            + "tscore.tstart as tstart,"
            + "player.pid as pid,"
            + "player.psurname as psurname,"
            + "player.pname as pname,"
            + "getplayerroundhc(tscore.trid,player.pid) AS hc,"
            + "getplayerscore(tscore.pid,tscore.trid,1) as qualif_score,"
            + "getplayerscorecsv(tscore.pid,tscore.trid,1) as qualif_score_csv,"
            + "getplayersum(tscore.pid,tscore.trid,1) as qualif_total,"
            + "getplayersumtotal(tscore.pid,tscore.trid,1) as qualif_total_hc,"
            + "getplayerscore(tscore.pid,tscore.trid,2) as final_score,"
            + "getplayerscorecsv(tscore.pid,tscore.trid,2) as final_score_csv,"
            + "getplayersum(tscore.pid,tscore.trid,2) as final_total,"
            + "getplayertotalavg(tscore.pid,tscore.trid) as total_avg,"
            + "getplayersumtotal(tscore.pid,tscore.trid,2) as final_total_hc,"
            + "getplayermaxstepscr(tscore.pid,tscore.trid,1) as kmax,"
            + "getplayermaxstepscr(tscore.pid,tscore.trid,2) as fmax,"
            + "getplayerpomscr(tscore.pid,tscore.trid,1,tscore.tstart) as kpomscr,"
            + "getplayerpomscr(tscore.pid,tscore.trid,2,tscore.tstart) as fpomscr,"
            + "tscore.tcount as tcount "
            + "FROM tscore,player "
            + "WHERE tscore.trid=? AND tscore.tstep=1 AND tscore.tcount='Y' AND player.pid=tscore.pid "
            + "GROUP BY tscore.tstep,tscore.trid, tscore.pid, tscore.tround, tscore.tstart, tscore.tcount, player.pid, player.psurname, player.pname "
            + "ORDER BY tstep DESC, final_total_hc DESC NULLS LAST, final_total DESC NULLS LAST, fmax DESC, fpomscr DESC, qualif_total_hc DESC, qualif_total DESC, kmax DESC, kpomscr DESC";
    public static final String sqlQueryB = "SELECT "
            + "tscore.tstep as tstep,"
            + "tscore.tround as tround,"
            + "tscore.tstart as tstart,"
            + "player.pid as pid,"
            + "player.psurname as psurname,"
            + "player.pname as pname,"
            + "getplayerroundhc(tscore.trid,player.pid) AS hc,"
            + "getplayerscore(tscore.pid,tscore.trid,1) as qualif_score,"
            + "getplayerscorecsv(tscore.pid,tscore.trid,1) as qualif_score_csv,"
            + "getplayersum(tscore.pid,tscore.trid,1) as qualif_total,"
            + "getplayersumtotal(tscore.pid,tscore.trid,1) as qualif_total_hc,"
            + "getplayertotalavgr(tscore.pid,tscore.trid,1,tscore.tstart) as qualif_avg,"
            + "getplayerscore(tscore.pid,tscore.trid,2) as final_score,"
            + "getplayerscorecsv(tscore.pid,tscore.trid,2) as final_score_csv,"
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
            + "FROM tscore,player "
            + "WHERE tscore.trid=? AND tscore.tstep=1 AND tscore.tcount='Y' AND player.pid=tscore.pid "
            + "GROUP BY tscore.tstep,tscore.trid, tscore.pid, tscore.tround, tscore.tstart, tscore.tcount, player.pid, player.psurname, player.pname "
            + "ORDER BY tstep DESC, tournament_total_hc DESC NULLS LAST, tournament_total DESC NULLS LAST, fmax DESC, fpomscr DESC, qualif_total_hc DESC, qualif_total DESC, kmax DESC, kpomscr DESC";
    public static final String sqlQueryA = "SELECT "
            + "tscore.tstep as tstep,"
            + "tscore.tround as tround,"
            + "tscore.tstart as tstart,"
            + "player.pid as pid,"
            + "player.psurname as psurname,"
            + "player.pname as pname,"
            + "getplayerroundhc(tscore.trid,player.pid) AS hc,"
            + "getplayerscore(tscore.pid,tscore.trid,1) as qualif_score,"
            + "getplayerscorecsv(tscore.pid,tscore.trid,1) as qualif_score_csv,"
            + "getplayersum(tscore.pid,tscore.trid,1) as qualif_total,"
            + "getplayersumtotal(tscore.pid,tscore.trid,1) as qualif_total_hc," //potrebujeme pro trideni lidi nepostupujicich do finale
            + "getplayerscore(tscore.pid,tscore.trid,2) as final_score,"
            + "getplayerscorecsv(tscore.pid,tscore.trid,2) as final_score_csv,"
            + "getplayersum(tscore.pid,tscore.trid,2) as final_total,"
            + "getplayertotalavg(tscore.pid,tscore.trid) as total_avg,"
            + "(getplayersum(tscore.pid,tscore.trid,1) + getplayersum(tscore.pid,tscore.trid,2)) AS total,"
            + "(getplayersumtotal(tscore.pid,tscore.trid,1) + getplayersumtotal(tscore.pid,tscore.trid,2)) AS total_hc,"
            + "getplayermaxstepscr(tscore.pid,tscore.trid,1) as kmax,"
            + "getplayermaxstepscr(tscore.pid,tscore.trid,2) as fmax,"
            + "getplayerpomscr(tscore.pid,tscore.trid,1,tscore.tstart) as kpomscr,"
            + "getplayerpomscr(tscore.pid,tscore.trid,2,tscore.tstart) as fpomscr,"
            + "tscore.tcount as tcount "
            + "FROM tscore,player "
            + "WHERE tscore.trid=? AND tscore.tstep=1 AND tscore.tcount='Y' AND player.pid=tscore.pid "
            + "GROUP BY tscore.tstep,tscore.trid,tscore.pid,tscore.tround,tscore.tstart,tscore.tcount,player.pid,player.psurname,player.pname "
            + "ORDER BY tstep DESC,total_hc DESC NULLS LAST,total DESC NULLS LAST,fmax DESC,fpomscr DESC,qualif_total_hc DESC,qualif_total DESC,kmax DESC,kpomscr DESC";

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

        //promene pro request
        int p = 0;
        int body = 0;

        //html
        try {

            out.println("<html>");
            out.println("<head>");
            out.println("<title>BT - ukončení turnaje</title>");
            out.println("<link rel='StyleSheet' href='css/tables.css' type='text/css'>");
            out.println("</head>");
            out.println("<body>");

            //vypiseme rozdelene body a zobrazime dialog pro ukonceni turnaje
            if (dbPool.isInitErr()) {

                out.println("<h2>Ukončení turnaje - DB pool exception:</h2>" + dbPool.getInitErrTxt());

            } else { //zpracujeme data pro editacni formulare

                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet resultSet = null;

                try {

                    out.println("<form method='post' action='Tfinish' target='_top'>");
                    out.println("<table>");
                    out.println("<caption>Ukončení turnaje </caption>");

                    conn = dbPool.getDBConn();
                    //pocet bodu
                    pstmt = conn.prepareStatement("SELECT count(*) FROM (SELECT pid FROM tscore WHERE trid=? AND tcount='Y' GROUP BY pid) AS body");
                    pstmt.setInt(1, (Integer) session.getAttribute("trID"));
                    resultSet = pstmt.executeQuery();
                    resultSet.next();
                    body = resultSet.getInt(1);

                    out.println("<thead><tr><th>&nbsp;</th><th>Hráč</th><th>body</th></tr></thead>");
                    out.println("<tfoot><tr><td colspan='3'>Ukončit a zapsat body<br/> do celkového pořadí?<br/><input type='submit' value='ANO'/><input type='hidden' name='ps' value='" + body + "'></td></tr></tfoot>");

                    if (session.getAttribute("tType").equals("C")) {
                        pstmt = conn.prepareStatement(sqlQueryC);
                    } else if (session.getAttribute("tType").equals("B")) {
                        pstmt = conn.prepareStatement(sqlQueryB);
                    } else {
                        pstmt = conn.prepareStatement(sqlQueryA);
                    }

                    pstmt.setInt(1, (Integer) session.getAttribute("trID"));

                    resultSet = pstmt.executeQuery();

                    out.println("<tbody>");
                    while (resultSet.next()) {
                        p += 1;
                        out.println("<tr><td>" + p + ".</td><td style='text-align: left'>" + resultSet.getString("psurname") + " " + resultSet.getString("pname") + "</td><td>" + body + "</td></tr>");
                        body -= 1;
                    }
                    out.println("</tbody>");

                    pstmt.close();
                    conn.close();

                } catch (SQLException e) {

                    out.println("<tfoot><tr><td colspan='3'><span style='color: red'>Chyba SQL: " + e.getMessage() + "</span></td></tr></tfoot>");

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

                out.println("</tfoot>");
                out.println("</table>");
                out.println("</form>");

                out.println("</body>");
                out.println("</html>");
            }

        } finally {
            out.close();
        }

    } //end GET

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
        String backPage = "index.jsp";
        PreparedStatement pstmtUpdate = null;
        //promene pro request
        int body = Integer.valueOf(request.getParameter("ps"));

        //nastavime spravne kodovani
        request.setCharacterEncoding("UTF-8");

        if (dbPool.isInitErr()) {

            msg = "<h2>Ukončení turnaje - DB pool exception:</h2>" + dbPool.getInitErrTxt();

        } else { //zpracujeme zapis bodů

            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet resultSet = null;

            try {

                conn = dbPool.getDBConn();
                if (session.getAttribute("tType").equals("C")) {
                    pstmt = conn.prepareStatement(sqlQueryC);
                } else if (session.getAttribute("tType").equals("B")) {
                    pstmt = conn.prepareStatement(sqlQueryB);
                } else {
                    pstmt = conn.prepareStatement(sqlQueryA);
                }
                pstmt.setInt(1, (Integer) session.getAttribute("trID"));

                resultSet = pstmt.executeQuery();

                //pro hrace dle poradi zapiseme prislesny pocet bodu
                while (resultSet.next()) {
                    //provedeme update bodu hrace - casem dodelat transakci
                    pstmtUpdate = conn.prepareStatement("UPDATE tpresentation SET body=? WHERE pid=? AND trid=?");
                    pstmtUpdate.setInt(1, body);
                    pstmtUpdate.setInt(2, resultSet.getInt("pid"));
                    pstmtUpdate.setInt(3, (Integer) session.getAttribute("trID"));
                    pstmtUpdate.executeUpdate();
                    body -= 1;
                }
                pstmtUpdate = conn.prepareStatement("UPDATE tround SET tend='Y' WHERE trid=?");
                pstmtUpdate.setInt(1, (Integer) session.getAttribute("trID"));
                pstmtUpdate.executeUpdate();
                pstmtUpdate.close();

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


            //presmerovani na stranku kde probehne info o probehlem pozadavku
            session.setAttribute("s_msg", msg);
            response.sendRedirect(response.encodeRedirectURL(backPage));
        }

    }
}
