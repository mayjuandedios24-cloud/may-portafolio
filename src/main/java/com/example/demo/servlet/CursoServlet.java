package com.example.demo.servlet;

import com.example.demo.dao.CursoDAO;
import com.example.demo.dao.TrabajoDAO;
import com.example.demo.model.Curso;
import com.example.demo.model.Semana;
import com.example.demo.model.Trabajo;
import com.example.demo.model.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet de vista del Curso.
 * GET /curso          → detalle-curso.jsp (vista general de semanas)
 * GET /curso?semana=N → detalle-semanal.jsp (trabajos de una semana)
 *
 * El ID del curso siempre es 1 (único curso en el sistema).
 * Compatible con roles ESTUDIANTE y DOCENTE (backUrl dinámico).
 */
@WebServlet("/curso")
public class CursoServlet extends HttpServlet {

    private final CursoDAO   cursoDAO   = new CursoDAO();
    private final TrabajoDAO trabajoDAO = new TrabajoDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Usuario usuario     = (session != null) ? (Usuario) session.getAttribute("usuarioLogueado") : null;

        String semanaParam = request.getParameter("semana");
        String rolUsuario  = (usuario != null) ? usuario.getRol() : "ESTUDIANTE";

        // Back URL dinámica según rol
        String backUrl = "DOCENTE".equalsIgnoreCase(rolUsuario)
            ? request.getContextPath() + "/panel-docente"
            : request.getContextPath() + "/panel-estudiante";

        Curso        curso   = cursoDAO.obtenerCursoPrincipal();
        List<Semana> semanas = cursoDAO.obtenerSemanas();

        request.setAttribute("usuario",     usuario);
        request.setAttribute("rolUsuario",  rolUsuario);
        request.setAttribute("backUrl",     backUrl);

        if (semanaParam != null && !semanaParam.trim().isEmpty()) {
            // ---- Vista detalle de una semana específica ----
            int numSemana;
            try { numSemana = Integer.parseInt(semanaParam.trim()); }
            catch (NumberFormatException e) { numSemana = 1; }

            List<Trabajo> trabajosSemana = trabajoDAO.obtenerPorCursoYSemana("1", semanaParam.trim());

            // Buscar datos de la semana actual
            Semana semanaActual = null;
            for (Semana s : semanas) {
                if (s.getNumero() == numSemana) { semanaActual = s; break; }
            }

            String tituloSemana = "Semana " + numSemana + ": " +
                (semanaActual != null ? semanaActual.getTitulo() : "Actividades Académicas");

            request.setAttribute("curso",        curso);
            request.setAttribute("semanaNum",    numSemana);
            request.setAttribute("semanaActual", semanaActual);
            request.setAttribute("tituloSemana", tituloSemana);
            request.setAttribute("trabajos",     trabajosSemana);
            request.getRequestDispatcher("/WEB-INF/views/detalle-semanal.jsp").forward(request, response);

        } else {
            // ---- Vista general del curso (todas las semanas) ----
            List<Trabajo> todosTrabajos = trabajoDAO.obtenerPorCurso("1");

            // Conteo de trabajos por semana para mostrar badge
            Map<Integer, Integer> conteoSemanal = new HashMap<>();
            for (Semana s : semanas) conteoSemanal.put(s.getNumero(), 0);
            for (Trabajo t : todosTrabajos) {
                int n = t.getSemanaNumero();
                conteoSemanal.put(n, conteoSemanal.getOrDefault(n, 0) + 1);
            }

            request.setAttribute("curso",         curso);
            request.setAttribute("semanas",        semanas);
            request.setAttribute("trabajos",       todosTrabajos);
            request.setAttribute("totalTrabajos",  todosTrabajos.size());
            request.setAttribute("conteoSemanal",  conteoSemanal);
            request.getRequestDispatcher("/WEB-INF/views/detalle-curso.jsp").forward(request, response);
        }
    }
}
