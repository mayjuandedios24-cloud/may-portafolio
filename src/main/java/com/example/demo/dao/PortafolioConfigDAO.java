package com.example.demo.dao;

import com.example.demo.config.DBConnection;
import com.example.demo.model.PortafolioConfig;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class PortafolioConfigDAO {

    public PortafolioConfig obtenerConfiguracion(Long estudianteId) {
        if (estudianteId == null) estudianteId = 1L;
        String sql = "SELECT * FROM portafolio_config WHERE estudiante_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, estudianteId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[PortafolioConfigDAO] Error al consultar configuración: " + e.getMessage());
        }
        PortafolioConfig fallback = new PortafolioConfig();
        fallback.setEstudianteId(estudianteId);
        return fallback;
    }

    public PortafolioConfig obtenerConfiguracionPrincipal() {
        return obtenerConfiguracion(1L);
    }

    public boolean guardarOActualizarConfiguracion(PortafolioConfig c) {
        if (c.getEstudianteId() == null) c.setEstudianteId(1L);

        String sql = "INSERT INTO portafolio_config (estudiante_id, hero_nombre, hero_titulo, hero_frases, " +
                "hero_descripcion, hero_imagen, github_url, linkedin_url, instagram_url, whatsapp_numero, " +
                "about_titulo, about_descripcion, about_filosofia, about_mision, about_imagen, " +
                "educacion_data, habilidades_data) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) " +
                "ON DUPLICATE KEY UPDATE " +
                "hero_nombre = VALUES(hero_nombre), hero_titulo = VALUES(hero_titulo), " +
                "hero_frases = VALUES(hero_frases), hero_descripcion = VALUES(hero_descripcion), " +
                "hero_imagen = VALUES(hero_imagen), github_url = VALUES(github_url), " +
                "linkedin_url = VALUES(linkedin_url), instagram_url = VALUES(instagram_url), " +
                "whatsapp_numero = VALUES(whatsapp_numero), about_titulo = VALUES(about_titulo), " +
                "about_descripcion = VALUES(about_descripcion), about_filosofia = VALUES(about_filosofia), " +
                "about_mision = VALUES(about_mision), about_imagen = VALUES(about_imagen), " +
                "educacion_data = VALUES(educacion_data), habilidades_data = VALUES(habilidades_data)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, c.getEstudianteId());
            stmt.setString(2, c.getHeroNombre());
            stmt.setString(3, c.getHeroTitulo());
            stmt.setString(4, c.getHeroFrases());
            stmt.setString(5, c.getHeroDescripcion());
            stmt.setString(6, c.getHeroImagen());
            stmt.setString(7, c.getGithubUrl());
            stmt.setString(8, c.getLinkedinUrl());
            stmt.setString(9, c.getInstagramUrl());
            stmt.setString(10, c.getWhatsappNumero());
            stmt.setString(11, c.getAboutTitulo());
            stmt.setString(12, c.getAboutDescripcion());
            stmt.setString(13, c.getAboutFilosofia());
            stmt.setString(14, c.getAboutMision());
            stmt.setString(15, c.getAboutImagen());
            stmt.setString(16, c.getEducacionData());
            stmt.setString(17, c.getHabilidadesData());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[PortafolioConfigDAO] Error al guardar configuración de portafolio: " + e.getMessage());
        }
        return false;
    }

    private PortafolioConfig mapRow(ResultSet rs) throws SQLException {
        PortafolioConfig c = new PortafolioConfig();
        c.setId(rs.getLong("id"));
        c.setEstudianteId(rs.getLong("estudiante_id"));
        c.setHeroNombre(rs.getString("hero_nombre"));
        c.setHeroTitulo(rs.getString("hero_titulo"));
        c.setHeroFrases(rs.getString("hero_frases"));
        c.setHeroDescripcion(rs.getString("hero_descripcion"));
        c.setHeroImagen(rs.getString("hero_imagen"));
        c.setGithubUrl(rs.getString("github_url"));
        c.setLinkedinUrl(rs.getString("linkedin_url"));
        c.setInstagramUrl(rs.getString("instagram_url"));
        c.setWhatsappNumero(rs.getString("whatsapp_numero"));
        c.setAboutTitulo(rs.getString("about_titulo"));
        c.setAboutDescripcion(rs.getString("about_descripcion"));
        c.setAboutFilosofia(rs.getString("about_filosofia"));
        c.setAboutMision(rs.getString("about_mision"));
        c.setAboutImagen(rs.getString("about_imagen"));
        c.setEducacionData(rs.getString("educacion_data"));
        c.setHabilidadesData(rs.getString("habilidades_data"));
        return c;
    }
}
