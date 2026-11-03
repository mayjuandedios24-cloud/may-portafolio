package com.example.demo.servlet;

import com.example.demo.dao.CursoDAO;
import com.example.demo.dao.TrabajoDAO;
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

import java.io.File;
import java.io.IOException;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet de gestión de Trabajos / Entregas académicas.
 * GET  /trabajo        → vista detalle del curso con todos los trabajos
 * GET  /trabajo?action=eliminar&id=X → eliminar trabajo y redirigir
 * POST /trabajo?action=guardar → crear nuevo trabajo (con archivo o URL)
 * POST /trabajo?action=editar  → editar trabajo existente
 *
 * Soporta subida de archivos ZIP/RAR/PDF hasta 100MB.
 */
@WebServlet("/trabajo")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,   // 2MB en RAM antes de ir a disco
    maxFileSize       = 1024 * 1024 * 100,  // 100MB por archivo
    maxRequestSize    = 1024 * 1024 * 150   // 150MB por petición completa
)
public class TrabajoServlet extends HttpServlet {

    private final TrabajoDAO trabajoDAO = new TrabajoDAO();
    private final CursoDAO   cursoDAO   = new CursoDAO();

    // ----------------------------------------------------------------
    // GET
    // ----------------------------------------------------------------
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action      = request.getParameter("action");
        String semanaOrigen = request.getParameter("semanaOrigen");

        // Eliminar trabajo
        if ("eliminar".equals(action)) {
            String id = request.getParameter("id");
            if (id != null && !id.trim().isEmpty()) {
                trabajoDAO.eliminarTrabajo(id.trim());
            }
            if (semanaOrigen != null && !semanaOrigen.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/curso?semana=" + semanaOrigen);
            } else {
                response.sendRedirect(request.getContextPath() + "/curso");
            }
            return;
        }

        // Vista de todos los trabajos del curso
        HttpSession session = request.getSession(false);
        Usuario usuario  = (session != null) ? (Usuario) session.getAttribute("usuarioLogueado") : null;
        String rolUsuario = (usuario != null) ? usuario.getRol() : "ESTUDIANTE";

        String backUrl = "DOCENTE".equalsIgnoreCase(rolUsuario)
            ? request.getContextPath() + "/panel-docente"
            : request.getContextPath() + "/panel-estudiante";

        Curso        curso   = cursoDAO.obtenerCursoPrincipal();
        List<Semana> semanas = cursoDAO.obtenerSemanas();
        List<Trabajo> trabajos = trabajoDAO.obtenerPorCurso("1");

        Map<Integer, Integer> conteoSemanal = new HashMap<>();
        for (Semana s : semanas) conteoSemanal.put(s.getNumero(), 0);
        for (Trabajo t : trabajos) {
            int n = t.getSemanaNumero();
            conteoSemanal.put(n, conteoSemanal.getOrDefault(n, 0) + 1);
        }

        request.setAttribute("curso",         curso);
        request.setAttribute("semanas",       semanas);
        request.setAttribute("trabajos",      trabajos);
        request.setAttribute("totalTrabajos", trabajos.size());
        request.setAttribute("conteoSemanal", conteoSemanal);
        request.setAttribute("rolUsuario",    rolUsuario);
        request.setAttribute("backUrl",       backUrl);
        request.getRequestDispatcher("/WEB-INF/views/detalle-curso.jsp").forward(request, response);
    }

    // ----------------------------------------------------------------
    // POST
    // ----------------------------------------------------------------
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Usuario usuario = (session != null) ? (Usuario) session.getAttribute("usuarioLogueado") : null;
        Long   estudianteId     = (usuario != null) ? usuario.getId() : 1L;
        String estudianteNombre = (usuario != null) ? usuario.getNombreCompleto() : "Estudiante";

        String action       = request.getParameter("action");
        String redirectSem  = request.getParameter("redirectSemana");

        String semanaNumStr = request.getParameter("semanaNumero");
        int semanaNumero = 1;
        try { semanaNumero = Integer.parseInt(semanaNumStr.trim()); }
        catch (Exception ignored) {}

        String titulo       = safe(request.getParameter("titulo"));
        String descripcion  = safe(request.getParameter("descripcion"));
        String fecha        = safe(request.getParameter("fechaEntrega"));
        String estado       = safe(request.getParameter("estado"));
        String nota         = safe(request.getParameter("notaPersonal"));
        String tag          = safe(request.getParameter("categoriaTag"));
        String urlProyecto  = normalizeUrl(request.getParameter("urlProyecto"));

        // Subida de archivo físico
        String archivoNombre = procesarArchivo(request);

        if ("guardar".equals(action)) {
            if (estado == null || estado.isEmpty()) estado = "Entregado";
            if (fecha  == null || fecha.isEmpty())  fecha  = LocalDate.now().toString();
            if (titulo == null || titulo.isEmpty()) titulo = "Nueva Entrega Semana " + semanaNumero;

            Trabajo nuevo = new Trabajo(
                null, 1L, null, semanaNumero, estudianteId, estudianteNombre,
                titulo, descripcion != null ? descripcion : "",
                fecha, archivoNombre, urlProyecto, estado,
                nota != null ? nota : "",
                tag != null && !tag.isEmpty() ? tag : "Proyecto Práctico",
                null, null
            );
            trabajoDAO.agregarTrabajo(nuevo);

        } else if ("editar".equals(action)) {
            String id = safe(request.getParameter("id"));
            Trabajo existente = trabajoDAO.obtenerPorId(id);

            String calificacion      = safe(request.getParameter("calificacion"));
            String observacionDocente = safe(request.getParameter("observacionDocente"));

            if (existente != null) {
                if (archivoNombre == null) archivoNombre = existente.getArchivoNombre();
                if (urlProyecto   == null) urlProyecto   = existente.getUrlProyecto();
                if (calificacion  == null) calificacion  = existente.getCalificacion();
                if (observacionDocente == null) observacionDocente = existente.getObservacionDocente();
                if (estado == null) estado = existente.getEstado();
            }

            Trabajo editado = new Trabajo(
                id, 1L, null, semanaNumero, estudianteId, estudianteNombre,
                titulo, descripcion, fecha, archivoNombre, urlProyecto,
                estado, nota, tag, calificacion, observacionDocente
            );
            trabajoDAO.actualizarTrabajo(editado);
        }

        // Redirigir
        if (redirectSem != null && !redirectSem.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/curso?semana=" + redirectSem.trim());
        } else {
            response.sendRedirect(request.getContextPath() + "/curso");
        }
    }

    // ----------------------------------------------------------------
    // HELPERS
    // ----------------------------------------------------------------

    private String procesarArchivo(HttpServletRequest request) {
        try {
            Part filePart = request.getPart("archivoFile");
            if (filePart != null && filePart.getSize() > 0) {
                String submitted = filePart.getSubmittedFileName();
                if (submitted != null && !submitted.trim().isEmpty()) {
                    String clean = new File(submitted).getName().replaceAll("[^a-zA-Z0-9._-]", "_");
                    String nombre = System.currentTimeMillis() + "_" + clean;

                    String uploadPath = getServletContext().getRealPath("/uploads");
                    if (uploadPath == null) {
                        uploadPath = System.getProperty("user.dir") + File.separator + "uploads";
                    }
                    File dir = new File(uploadPath);
                    if (!dir.exists()) dir.mkdirs();
                    filePart.write(uploadPath + File.separator + nombre);
                    return nombre;
                }
            }
        } catch (Exception e) {
            System.err.println("[TrabajoServlet] Error procesando archivo: " + e.getMessage());
        }
        // Fallback: nombre de archivo escrito manualmente
        String manual = safe(request.getParameter("archivoNombreText"));
        return (manual != null && !manual.isEmpty()) ? manual : null;
    }

    private String safe(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private String normalizeUrl(String url) {
        if (url == null || url.trim().isEmpty()) return null;
        url = url.trim();
        if (!url.startsWith("http://") && !url.startsWith("https://")) url = "https://" + url;
        return url;
    }
}
