package com.example.demo.servlet;

import com.example.demo.dao.CursoDAO;
import com.example.demo.dao.PortafolioConfigDAO;
import com.example.demo.dao.PortafolioDAO;
import com.example.demo.dao.TrabajoDAO;
import com.example.demo.dao.UsuarioDAO;
import com.example.demo.model.*;

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
 * Servlet del Panel del Estudiante.
 * Maneja:
 *   - Vista principal: semanas, trabajos, estadísticas
 *   - Actualización del perfil (nombre, email, avatar con archivo local)
 *   - Cambio de contraseña y username
 *   - Gestión de proyectos del portafolio (con subida de imagen de preview)
 *   - Configuración dinámica del Portafolio Público (Inicio, Sobre Mí, Educación, Habilidades)
 */
@WebServlet("/panel-estudiante")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize       = 1024 * 1024 * 25,
    maxRequestSize    = 1024 * 1024 * 40
)
public class EstudianteServlet extends HttpServlet {

    private final CursoDAO            cursoDAO            = new CursoDAO();
    private final TrabajoDAO          trabajoDAO          = new TrabajoDAO();
    private final UsuarioDAO          usuarioDAO          = new UsuarioDAO();
    private final PortafolioDAO       portafolioDAO       = new PortafolioDAO();
    private final PortafolioConfigDAO portafolioConfigDAO = new PortafolioConfigDAO();

    // ----------------------------------------------------------------
    // GET — Vista principal del panel estudiante
    // ----------------------------------------------------------------
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Usuario usuario = (session != null) ? (Usuario) session.getAttribute("usuarioLogueado") : null;

        if (usuario == null || !"ESTUDIANTE".equalsIgnoreCase(usuario.getRol())) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?restricted=true");
            return;
        }

        String tab = request.getParameter("tab"); // semanas | perfil | portafolio | web

        Curso        cursoPrincipal = cursoDAO.obtenerCursoPrincipal();
        List<Semana> semanas        = cursoDAO.obtenerSemanas();
        List<Trabajo> trabajos      = trabajoDAO.obtenerPorEstudiante(usuario.getId());
        List<PortafolioProyecto> proyectos = portafolioDAO.obtenerPorEstudiante(usuario.getId());
        PortafolioConfig portafolioConfig = portafolioConfigDAO.obtenerConfiguracion(usuario.getId());

        // Estadísticas
        int totalTrabajos    = trabajos.size();
        int calificadosCount = 0;
        int pendientesCount  = 0;
        double sumaNotas     = 0;
        int countNotas       = 0;

        for (Trabajo t : trabajos) {
            if ("Calificado".equalsIgnoreCase(t.getEstado())) calificadosCount++;
            else pendientesCount++;

            if (t.getCalificacion() != null && !t.getCalificacion().trim().isEmpty()) {
                String cal = t.getCalificacion().trim();
                if (cal.contains("/")) cal = cal.split("/")[0].trim();
                try {
                    sumaNotas += Double.parseDouble(cal);
                    countNotas++;
                } catch (NumberFormatException ignored) {}
            }
        }

        String promedioNotas = countNotas > 0
            ? String.format(java.util.Locale.US, "%.1f / 20", sumaNotas / countNotas)
            : "--";

        String msgExito = request.getParameter("exito");
        String msgError = request.getParameter("error");

        request.setAttribute("usuario",          usuario);
        request.setAttribute("curso",            cursoPrincipal);
        request.setAttribute("semanas",          semanas);
        request.setAttribute("trabajos",         trabajos);
        request.setAttribute("proyectos",        proyectos);
        request.setAttribute("portafolioConfig", portafolioConfig);
        request.setAttribute("totalTrabajos",    totalTrabajos);
        request.setAttribute("calificadosCount", calificadosCount);
        request.setAttribute("pendientesCount",  pendientesCount);
        request.setAttribute("promedioNotas",    promedioNotas);
        request.setAttribute("tabActiva",        tab != null ? tab : "semanas");
        request.setAttribute("msgExito",         msgExito);
        request.setAttribute("msgError",         msgError);

        request.getRequestDispatcher("/WEB-INF/views/estudiante.jsp").forward(request, response);
    }

    // ----------------------------------------------------------------
    // POST — Acciones del estudiante
    // ----------------------------------------------------------------
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Usuario usuario = (session != null) ? (Usuario) session.getAttribute("usuarioLogueado") : null;

        if (usuario == null || !"ESTUDIANTE".equalsIgnoreCase(usuario.getRol())) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?restricted=true");
            return;
        }

        String action = request.getParameter("action");

        switch (action != null ? action : "") {

            // ---- Actualizar perfil (nombre, email, avatar con archivo) -----------
            case "actualizarPerfil": {
                String nombre = request.getParameter("nombreCompleto");
                String email  = request.getParameter("email");
                String avatar = request.getParameter("avatar");

                Part avatarFile = null;
                try {
                    avatarFile = request.getPart("avatarFile");
                } catch (Exception ignored) {}

                if (avatarFile != null && avatarFile.getSize() > 0) {
                    String subida = com.example.demo.util.FileUploadUtil.guardarImagen(avatarFile, getServletContext(), "avatar_est");
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
                    redirect(response, request.getContextPath() + "/panel-estudiante?tab=perfil&exito=perfil");
                } else {
                    redirect(response, request.getContextPath() + "/panel-estudiante?tab=perfil&error=perfil");
                }
                break;
            }

            // ---- Cambiar username ------------------------------------
            case "cambiarUsername": {
                String nuevoUsername = request.getParameter("nuevoUsername");
                if (nuevoUsername != null && !nuevoUsername.trim().isEmpty()) {
                    boolean ok = usuarioDAO.actualizarUsername(usuario.getId(), nuevoUsername);
                    if (ok) {
                        usuario.setUsername(nuevoUsername.trim());
                        session.setAttribute("usuarioLogueado", usuario);
                        redirect(response, request.getContextPath() + "/panel-estudiante?tab=perfil&exito=username");
                    } else {
                        redirect(response, request.getContextPath() + "/panel-estudiante?tab=perfil&error=username_tomado");
                    }
                } else {
                    redirect(response, request.getContextPath() + "/panel-estudiante?tab=perfil&error=username_tomado");
                }
                break;
            }

            // ---- Cambiar contraseña ---------------------------------
            case "cambiarPassword": {
                String actual   = request.getParameter("passwordActual");
                String nueva    = request.getParameter("passwordNueva");
                String confirma = request.getParameter("passwordConfirmar");

                if (nueva != null && !nueva.trim().isEmpty() && nueva.equals(confirma)) {
                    boolean ok = usuarioDAO.cambiarPassword(usuario.getId(), actual, nueva);
                    if (ok) {
                        usuario.setPassword(nueva.trim());
                        session.setAttribute("usuarioLogueado", usuario);
                        redirect(response, request.getContextPath() + "/panel-estudiante?tab=perfil&exito=password");
                    } else {
                        redirect(response, request.getContextPath() + "/panel-estudiante?tab=perfil&error=password_incorrecto");
                    }
                } else {
                    redirect(response, request.getContextPath() + "/panel-estudiante?tab=perfil&error=coincide");
                }
                break;
            }

            // ---- Agregar proyecto al portafolio ----------------------
            case "agregarProyecto": {
                PortafolioProyecto p = construirProyecto(request, usuario.getId(), null);
                boolean ok = portafolioDAO.agregarProyecto(p);
                redirect(response, request.getContextPath() + "/panel-estudiante?tab=portafolio"
                    + (ok ? "&exito=proyecto" : "&error=proyecto"));
                break;
            }

            // ---- Editar proyecto del portafolio ----------------------
            case "editarProyecto": {
                String idStr = request.getParameter("proyectoId");
                try {
                    Long pid = Long.parseLong(idStr.trim());
                    PortafolioProyecto p = construirProyecto(request, usuario.getId(), pid);
                    boolean ok = portafolioDAO.actualizarProyecto(p);
                    redirect(response, request.getContextPath() + "/panel-estudiante?tab=portafolio"
                        + (ok ? "&exito=proyecto" : "&error=proyecto"));
                } catch (Exception e) {
                    redirect(response, request.getContextPath() + "/panel-estudiante?tab=portafolio&error=proyecto");
                }
                break;
            }

            // ---- Eliminar proyecto del portafolio -------------------
            case "eliminarProyecto": {
                String idStr = request.getParameter("proyectoId");
                try {
                    Long pid = Long.parseLong(idStr.trim());
                    boolean ok = portafolioDAO.eliminarProyecto(pid, usuario.getId());
                    redirect(response, request.getContextPath() + "/panel-estudiante?tab=portafolio"
                        + (ok ? "&exito=eliminado" : "&error=proyecto"));
                } catch (Exception e) {
                    redirect(response, request.getContextPath() + "/panel-estudiante?tab=portafolio&error=proyecto");
                }
                break;
            }

            // ---- Guardar Personalización del Portafolio Web Público ----
            case "guardarPortafolioWeb": {
                PortafolioConfig config = portafolioConfigDAO.obtenerConfiguracion(usuario.getId());
                config.setEstudianteId(usuario.getId());

                String heroNombre = request.getParameter("heroNombre");
                String heroTitulo = request.getParameter("heroTitulo");
                String heroFrases = request.getParameter("heroFrases");
                String heroDesc = request.getParameter("heroDescripcion");
                String github = request.getParameter("githubUrl");
                String linkedin = request.getParameter("linkedinUrl");
                String instagram = request.getParameter("instagramUrl");
                String whatsapp = request.getParameter("whatsappNumero");

                if (heroNombre != null && !heroNombre.trim().isEmpty()) config.setHeroNombre(heroNombre.trim());
                if (heroTitulo != null && !heroTitulo.trim().isEmpty()) config.setHeroTitulo(heroTitulo.trim());
                if (heroFrases != null && !heroFrases.trim().isEmpty()) config.setHeroFrases(heroFrases.trim());
                if (heroDesc != null) config.setHeroDescripcion(heroDesc.trim());
                if (github != null) config.setGithubUrl(github.trim());
                if (linkedin != null) config.setLinkedinUrl(linkedin.trim());
                if (instagram != null) config.setInstagramUrl(instagram.trim());
                if (whatsapp != null) config.setWhatsappNumero(whatsapp.trim());

                try {
                    Part heroPart = request.getPart("heroImagenFile");
                    if (heroPart != null && heroPart.getSize() > 0) {
                        String ruta = com.example.demo.util.FileUploadUtil.guardarImagen(heroPart, getServletContext(), "hero");
                        if (ruta != null) config.setHeroImagen(ruta);
                    } else {
                        String manual = request.getParameter("heroImagen");
                        if (manual != null && !manual.trim().isEmpty()) config.setHeroImagen(manual.trim());
                    }
                } catch (Exception ignored) {}

                String aboutTit = request.getParameter("aboutTitulo");
                String aboutDesc = request.getParameter("aboutDescripcion");
                String aboutFil = request.getParameter("aboutFilosofia");
                String aboutMis = request.getParameter("aboutMision");

                if (aboutTit != null && !aboutTit.trim().isEmpty()) config.setAboutTitulo(aboutTit.trim());
                if (aboutDesc != null) config.setAboutDescripcion(aboutDesc.trim());
                if (aboutFil != null) config.setAboutFilosofia(aboutFil.trim());
                if (aboutMis != null) config.setAboutMision(aboutMis.trim());

                try {
                    Part aboutPart = request.getPart("aboutImagenFile");
                    if (aboutPart != null && aboutPart.getSize() > 0) {
                        String ruta = com.example.demo.util.FileUploadUtil.guardarImagen(aboutPart, getServletContext(), "about");
                        if (ruta != null) config.setAboutImagen(ruta);
                    } else {
                        String manual = request.getParameter("aboutImagen");
                        if (manual != null && !manual.trim().isEmpty()) config.setAboutImagen(manual.trim());
                    }
                } catch (Exception ignored) {}

                String eduData = request.getParameter("educacionData");
                String habData = request.getParameter("habilidadesData");
                if (eduData != null) config.setEducacionData(eduData.trim());
                if (habData != null) config.setHabilidadesData(habData.trim());

                boolean ok = portafolioConfigDAO.guardarOActualizarConfiguracion(config);
                redirect(response, request.getContextPath() + "/panel-estudiante?tab=web" + (ok ? "&exito=web" : "&error=web"));
                break;
            }

            default:
                redirect(response, request.getContextPath() + "/panel-estudiante");
        }
    }

    // ----------------------------------------------------------------
    // HELPERS
    // ----------------------------------------------------------------

    private PortafolioProyecto construirProyecto(HttpServletRequest request,
                                                  Long estudianteId, Long id) {
        PortafolioProyecto p = new PortafolioProyecto();
        p.setId(id);
        p.setEstudianteId(estudianteId);
        p.setTitulo(safe(request.getParameter("titulo")));
        p.setDescripcion(safe(request.getParameter("descripcion")));
        p.setTecnologias(safe(request.getParameter("tecnologias")));
        p.setUrlDemo(normalizeUrl(request.getParameter("urlDemo")));
        p.setUrlRepositorio(normalizeUrl(request.getParameter("urlRepositorio")));

        // Imagen de preview: archivo físico o ruta de texto
        String imgPreview = safe(request.getParameter("imagenPreview"));
        try {
            Part imgPart = request.getPart("imagenPreviewFile");
            if (imgPart != null && imgPart.getSize() > 0) {
                String subida = com.example.demo.util.FileUploadUtil.guardarImagen(imgPart, getServletContext(), "proy_img");
                if (subida != null) {
                    imgPreview = subida;
                }
            }
        } catch (Exception ignored) {}

        p.setImagenPreview(imgPreview);
        p.setCategoria(safe(request.getParameter("categoria")));
        p.setDestacado("true".equals(request.getParameter("destacado")) ||
                       "1".equals(request.getParameter("destacado")));
        try {
            p.setOrden(Integer.parseInt(request.getParameter("orden")));
        } catch (Exception e) {
            p.setOrden(0);
        }
        return p;
    }

    private String safe(String s) {
        return s != null ? s.trim() : null;
    }

    private String normalizeUrl(String url) {
        if (url == null || url.trim().isEmpty()) return null;
        url = url.trim();
        if (!url.startsWith("http://") && !url.startsWith("https://")) {
            url = "https://" + url;
        }
        return url;
    }

    private void redirect(HttpServletResponse response, String url) throws IOException {
        response.sendRedirect(url);
    }
}
