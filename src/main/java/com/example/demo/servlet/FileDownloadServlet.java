package com.example.demo.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/download-archivo")
public class FileDownloadServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String nombre = request.getParameter("nombre");
        if (nombre == null || nombre.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Nombre de archivo no especificado");
            return;
        }

        nombre = URLDecoder.decode(nombre, StandardCharsets.UTF_8);
        
        // Protección contra Directory Traversal
        String cleanName = new File(nombre).getName();

        String uploadPath = getServletContext().getRealPath("/uploads");
        if (uploadPath == null) {
            uploadPath = System.getProperty("user.dir") + File.separator + "uploads";
        }

        File file = new File(uploadPath, cleanName);

        if (!file.exists() || file.isDirectory()) {
            // Intentar buscar en el directorio del proyecto
            File fallback = new File("src/main/webapp/uploads", cleanName);
            if (fallback.exists()) {
                file = fallback;
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "El archivo solicitado no existe en el servidor: " + cleanName);
                return;
            }
        }

        String contentType = getServletContext().getMimeType(file.getName());
        if (contentType == null) {
            if (file.getName().toLowerCase().endsWith(".zip")) {
                contentType = "application/zip";
            } else if (file.getName().toLowerCase().endsWith(".rar")) {
                contentType = "application/x-rar-compressed";
            } else if (file.getName().toLowerCase().endsWith(".pdf")) {
                contentType = "application/pdf";
            } else if (file.getName().toLowerCase().endsWith(".apk")) {
                contentType = "application/vnd.android.package-archive";
            } else {
                contentType = "application/octet-stream";
            }
        }

        response.setContentType(contentType);
        response.setContentLengthLong(file.length());
        response.setHeader("Content-Disposition", "attachment; filename=\"" + cleanName + "\"");

        try (InputStream in = new FileInputStream(file);
             OutputStream out = response.getOutputStream()) {
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
        }
    }
}
