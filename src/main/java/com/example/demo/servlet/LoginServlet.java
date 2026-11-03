package com.example.demo.servlet;

import com.example.demo.dao.UsuarioDAO;
import com.example.demo.model.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login-process")
public class LoginServlet extends HttpServlet {

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        Usuario usuario = usuarioDAO.validarUsuario(username, password);

        if (usuario != null) {
            HttpSession session = request.getSession(true);
            session.setAttribute("usuarioLogueado", usuario);

            if ("DOCENTE".equalsIgnoreCase(usuario.getRol())) {
                response.sendRedirect(request.getContextPath() + "/panel-docente");
            } else {
                response.sendRedirect(request.getContextPath() + "/panel-estudiante");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=true");
        }
    }
}
