package com.example.demo.util;

import jakarta.servlet.ServletContext;
import jakarta.servlet.http.Part;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

public class FileUploadUtil {

    public static String guardarImagen(Part filePart, ServletContext context, String prefix) {
        if (filePart == null || filePart.getSize() <= 0) return null;
        try {
            String submitted = filePart.getSubmittedFileName();
            if (submitted == null || submitted.trim().isEmpty()) return null;

            String clean = new File(submitted).getName().replaceAll("[^a-zA-Z0-9._-]", "_");
            String nombre = prefix + "_" + System.currentTimeMillis() + "_" + clean;

            // 1. Guardar en el directorio de ejecución del webapp
            String uploadPath = context.getRealPath("/uploads");
            if (uploadPath == null) {
                uploadPath = System.getProperty("user.dir") + File.separator + "uploads";
            }
            File dir = new File(uploadPath);
            if (!dir.exists()) dir.mkdirs();

            File destFile = new File(dir, nombre);
            filePart.write(destFile.getAbsolutePath());

            // 2. Copiar a src/main/webapp/uploads si está en entorno local para que no se pierda al reiniciar
            try {
                String localSrcPath = System.getProperty("user.dir") + File.separator + "src" +
                        File.separator + "main" + File.separator + "webapp" + File.separator + "uploads";
                File localDir = new File(localSrcPath);
                if (!localDir.exists()) localDir.mkdirs();
                File localFile = new File(localDir, nombre);
                Files.copy(destFile.toPath(), localFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
            } catch (Exception ignored) {}

            return "uploads/" + nombre;
        } catch (Exception e) {
            System.err.println("[FileUploadUtil] Error al procesar subida de imagen: " + e.getMessage());
            return null;
        }
    }
}
