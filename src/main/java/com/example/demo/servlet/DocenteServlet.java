package com.example.demo.servlet;

import com.example.demo.dao.CursoDAO;
import com.example.demo.dao.TrabajoDAO;
import com.example.demo.dao.UsuarioDAO;
import com.example.demo.model.Curso;
import com.example.demo.model.Semana;
import com.example.demo.model.Trabajo;
import com.example.demo.model.Usuario;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.util.List;

/**
 * Servlet del Panel del Docente.
 * Maneja:
 *   - Vista principal con todos los trabajos / filtro por semana
 *   - Calificación de trabajos
 *   - Actualización del perfil del docente (nombre, email, avatar con archivo)
 *   - Cambio de contraseña del docente
 *   - Configuración dinámica de semanas del curso
 *   - Edición del título y descripción de cada semana
 */
@WebServlet("/panel-docente")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize       = 1024 * 1024 * 20,
    maxRequestSize    = 1024 * 1024 * 30
)
public class DocenteServlet extends HttpServlet {

    private final TrabajoDAO trabajoDAO = new TrabajoDAO();
    private final CursoDAO   cursoDAO   = new CursoDAO();
    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    // ----------------------------------------------------------------
    // GET — Vista principal del panel docente
    // ----------------------------------------------------------------
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Usuario usuario = (session != null) ? (Usuario) session.getAttribute("usuarioLogueado") : null;

        if (usuario == null || !"DOCENTE".equalsIgnoreCase(usuario.getRol())) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?restricted=true");
            return;
        }

        String semanaFiltro = request.getParameter("semana");
        String tab          = request.getParameter("tab"); // entregas | perfil | semanas

        Curso        cursoActual  = cursoDAO.obtenerCursoPrincipal();
        List<Semana> listaSemanas = cursoDAO.obtenerSemanas();

        List<Trabajo> trabajosFiltrados;
        List<Trabajo> todosTrabajos = trabajoDAO.obtenerPorCurso("1");

        if (semanaFiltro != null && !semanaFiltro.trim().isEmpty()) {
            trabajosFiltrados = trabajoDAO.obtenerPorCursoYSemana("1", semanaFiltro);
        } else {
            trabajosFiltrados = todosTrabajos;
        }

        int totalEntregables = todosTrabajos.size();
        int calificadosCount = 0;
        int pendientesCount  = 0;

        for (Trabajo t : todosTrabajos) {
            if ("Calificado".equalsIgnoreCase(t.getEstado())) calificadosCount++;
            else pendientesCount++;
        }

        // Mensaje de éxito/error desde redirect
        String msgExito = request.getParameter("exito");
        String msgError = request.getParameter("error");

        request.setAttribute("usuario",          usuario);
        request.setAttribute("cursoActual",      cursoActual);
        request.setAttribute("listaSemanas",     listaSemanas);
        request.setAttribute("trabajos",         trabajosFiltrados);
        request.setAttribute("totalEntregables", totalEntregables);
        request.setAttribute("calificadosCount", calificadosCount);
        request.setAttribute("pendientesCount",  pendientesCount);
        request.setAttribute("semanaFiltro",     semanaFiltro);
        request.setAttribute("tabActiva",        tab != null ? tab : "entregas");
        request.setAttribute("msgExito",         msgExito);
        request.setAttribute("msgError",         msgError);

        request.getRequestDispatcher("/WEB-INF/views/docente.jsp").forward(request, response);
    }

    // ----------------------------------------------------------------
    // POST — Acciones del docente
    // ----------------------------------------------------------------
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Usuario usuario = (session != null) ? (Usuario) session.getAttribute("usuarioLogueado") : null;

        if (usuario == null || !"DOCENTE".equalsIgnoreCase(usuario.getRol())) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?restricted=true");
            return;
        }

        String action = request.getParameter("action");
        String semana = request.getParameter("semana");

        switch (action != null ? action : "") {

            // ---- Calificar un trabajo ----------------------------------
            case "calificar": {
                String id               = request.getParameter("id");
                String estado           = request.getParameter("estado");
                String calificacion     = request.getParameter("calificacion");
                String observacion      = request.getParameter("observacionDocente");

                boolean calOk = false;
                if (id != null && !id.trim().isEmpty()) {
                    if (estado == null || estado.trim().isEmpty()) estado = "Calificado";
                    if (calificacion == null || calificacion.trim().isEmpty()) calificacion = "20/20";
                    calOk = trabajoDAO.actualizarCalificacionDocente(
                        id.trim(), estado.trim(),
                        calificacion.trim(),
                        observacion != null ? observacion.trim() : ""
                    );
                }
                String redirectCal = request.getContextPath() + "/panel-docente?tab=entregas"
                    + (semana != null && !semana.trim().isEmpty() ? "&semana=" + semana.trim() : "")
                    + (calOk ? "&exito=calificado" : "&error=calificar");
                redirect(response, redirectCal);
                break;
            }

            // ---- Actualizar perfil del docente ------------------------
            case "actualizarPerfil": {
                String nombre = request.getParameter("nombreCompleto");
                String email  = request.getParameter("email");
                String avatar = request.getParameter("avatar");

                Part avatarFile = null;
                try {
                    avatarFile = request.getPart("avatarFile");
                } catch (Exception ignored) {}

                if (avatarFile != null && avatarFile.getSize() > 0) {
                    String subida = com.example.demo.util.FileUploadUtil.guardarImagen(avatarFile, getServletContext(), "avatar_doc");
                    if (subida != null) {
                        avatar = subida;
                    }
                }

                if (avatar == null || avatar.trim().isEmpty()) {
                    avatar = usuario.getAvatar();
                }

                boolean ok = usuarioDAO.actualizarPerfil(usuario.getId(), nombre, email, avatar);
                if (ok) {
                    if (nombre != null && !nombre.trim().isEmpty()) usuario.setNombreCompleto(nombre.trim());
                    if (email != null && !email.trim().isEmpty()) usuario.setEmail(email.trim());
                    if (avatar != null && !avatar.trim().isEmpty()) usuario.setAvatar(avatar.trim());
                    session.setAttribute("usuarioLogueado", usuario);
                    redirect(response, request.getContextPath() + "/panel-docente?tab=perfil&exito=perfil");
                } else {
                    redirect(response, request.getContextPath() + "/panel-docente?tab=perfil&error=perfil");
                }
                break;
            }

            // ---- Cambiar contraseña del docente -----------------------
            case "cambiarPassword": {
                String actual   = request.getParameter("passwordActual");
                String nueva    = request.getParameter("passwordNueva");
                String confirma = request.getParameter("passwordConfirmar");

                if (nueva != null && !nueva.trim().isEmpty() && nueva.equals(confirma)) {
                    boolean ok = usuarioDAO.cambiarPassword(usuario.getId(), actual, nueva);
                    if (ok) {
                        usuario.setPassword(nueva.trim());
                        session.setAttribute("usuarioLogueado", usuario);
                        redirect(response, request.getContextPath() + "/panel-docente?tab=perfil&exito=password");
                    } else {
                        redirect(response, request.getContextPath() + "/panel-docente?tab=perfil&error=password_incorrecto");
                    }
                } else {
                    redirect(response, request.getContextPath() + "/panel-docente?tab=perfil&error=coincide");
                }
                break;
            }

            // ---- Configurar número de semanas del curso ---------------
            case "configurarSemanas": {
                String totalStr = request.getParameter("totalSemanas");
                try {
                    int total = Integer.parseInt(totalStr.trim());
                    boolean ok = cursoDAO.configurarTotalSemanas(1L, total);
                    redirect(response, request.getContextPath() + "/panel-docente?tab=semanas"
                        + (ok ? "&exito=semanas" : "&error=semanas"));
                } catch (Exception e) {
                    redirect(response, request.getContextPath() + "/panel-docente?tab=semanas&error=semanas");
                }
                break;
            }

            // ---- Editar título y descripción de una semana -----------
            case "editarSemana": {
                String semanaIdStr   = request.getParameter("semanaId");
                String titulo        = request.getParameter("tituloSemana");
                String descripcion   = request.getParameter("descripcionSemana");
                String fechaLimite   = request.getParameter("fechaLimite");
                try {
                    Long semanaId = Long.parseLong(semanaIdStr.trim());
                    boolean ok = cursoDAO.actualizarSemana(semanaId, titulo, descripcion, fechaLimite);
                    redirect(response, request.getContextPath() + "/panel-docente?tab=semanas"
                        + (ok ? "&exito=semana" : "&error=semana"));
                } catch (Exception e) {
                    redirect(response, request.getContextPath() + "/panel-docente?tab=semanas&error=semana");
                }
                break;
            }

            default:
                redirect(response, request.getContextPath() + "/panel-docente");
        }
    }

    private void redirect(HttpServletResponse response, String url) throws IOException {
        response.sendRedirect(url);
    }
}
