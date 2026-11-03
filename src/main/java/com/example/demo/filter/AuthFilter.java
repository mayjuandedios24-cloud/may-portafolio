package com.example.demo.filter;

import com.example.demo.model.Usuario;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Filtro de Autenticación y Autorización por Rol.
 * Protege todas las rutas que requieren sesión activa.
 * También valida que el DOCENTE no acceda al panel de ESTUDIANTE y viceversa.
 */
@WebFilter(urlPatterns = {
    "/panel-estudiante",
    "/panel-docente",
    "/curso",
    "/trabajo"
})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        Usuario usuario = (session != null) ? (Usuario) session.getAttribute("usuarioLogueado") : null;

        // Sin sesión → redirigir al login
        if (usuario == null) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp?restricted=true");
            return;
        }

        String uri = req.getRequestURI();
        String ctx = req.getContextPath();

        // DOCENTE intentando acceder al panel de ESTUDIANTE → redirigir
        if (uri.startsWith(ctx + "/panel-estudiante") && !"ESTUDIANTE".equalsIgnoreCase(usuario.getRol())) {
            resp.sendRedirect(ctx + "/panel-docente");
            return;
        }

        // ESTUDIANTE intentando acceder al panel de DOCENTE → redirigir
        if (uri.startsWith(ctx + "/panel-docente") && !"DOCENTE".equalsIgnoreCase(usuario.getRol())) {
            resp.sendRedirect(ctx + "/panel-estudiante");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
