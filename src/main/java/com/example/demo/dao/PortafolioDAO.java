package com.example.demo.dao;

import com.example.demo.config.DBConnection;
import com.example.demo.model.PortafolioProyecto;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO del Portafolio Web del Estudiante.
 * Soporta: listar proyectos, agregar, editar, eliminar y marcar destacados.
 */
public class PortafolioDAO {

    // ----------------------------------------------------------------
    // LECTURA
    // ----------------------------------------------------------------

    /**
     * Obtiene todos los proyectos del portafolio de un estudiante,
     * ordenados por destacado DESC y orden ASC.
     */
    public List<PortafolioProyecto> obtenerPorEstudiante(Long estudianteId) {
        List<PortafolioProyecto> lista = new ArrayList<>();
        String sql = "SELECT id, estudiante_id, titulo, descripcion, tecnologias, url_demo, " +
                     "url_repositorio, imagen_preview, categoria, destacado, orden, " +
                     "DATE_FORMAT(fecha_creacion, '%d/%m/%Y') AS fecha_creacion, " +
                     "DATE_FORMAT(fecha_actualizacion, '%d/%m/%Y') AS fecha_actualizacion " +
                     "FROM portafolio_proyectos WHERE estudiante_id = ? " +
                     "ORDER BY destacado DESC, orden ASC, fecha_creacion DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, estudianteId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) lista.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[PortafolioDAO] Error al listar proyectos: " + e.getMessage());
        }
        return lista;
    }

    public PortafolioProyecto obtenerPorId(Long id) {
        String sql = "SELECT id, estudiante_id, titulo, descripcion, tecnologias, url_demo, " +
                     "url_repositorio, imagen_preview, categoria, destacado, orden, " +
                     "DATE_FORMAT(fecha_creacion, '%d/%m/%Y') AS fecha_creacion, " +
                     "DATE_FORMAT(fecha_actualizacion, '%d/%m/%Y') AS fecha_actualizacion " +
                     "FROM portafolio_proyectos WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[PortafolioDAO] Error al obtener proyecto por ID: " + e.getMessage());
        }
        return null;
    }

    // ----------------------------------------------------------------
    // ESCRITURA
    // ----------------------------------------------------------------

    public boolean agregarProyecto(PortafolioProyecto p) {
        String sql = "INSERT INTO portafolio_proyectos " +
                     "(estudiante_id, titulo, descripcion, tecnologias, url_demo, url_repositorio, " +
                     "imagen_preview, categoria, destacado, orden) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setLong(1, p.getEstudianteId());
            stmt.setString(2, p.getTitulo());
            stmt.setString(3, p.getDescripcion());
            stmt.setString(4, p.getTecnologias());
            stmt.setString(5, p.getUrlDemo());
            stmt.setString(6, p.getUrlRepositorio());
            stmt.setString(7, p.getImagenPreview());
            stmt.setString(8, p.getCategoria());
            stmt.setBoolean(9, p.isDestacado());
            stmt.setInt(10, p.getOrden());
            int rows = stmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) p.setId(keys.getLong(1));
                }
                return true;
            }
        } catch (SQLException e) {
            System.err.println("[PortafolioDAO] Error al agregar proyecto: " + e.getMessage());
        }
        return false;
    }

    public boolean actualizarProyecto(PortafolioProyecto p) {
        String sql = "UPDATE portafolio_proyectos SET titulo = ?, descripcion = ?, tecnologias = ?, " +
                     "url_demo = ?, url_repositorio = ?, imagen_preview = ?, categoria = ?, " +
                     "destacado = ?, orden = ? WHERE id = ? AND estudiante_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, p.getTitulo());
            stmt.setString(2, p.getDescripcion());
            stmt.setString(3, p.getTecnologias());
            stmt.setString(4, p.getUrlDemo());
            stmt.setString(5, p.getUrlRepositorio());
            stmt.setString(6, p.getImagenPreview());
            stmt.setString(7, p.getCategoria());
            stmt.setBoolean(8, p.isDestacado());
            stmt.setInt(9, p.getOrden());
            stmt.setLong(10, p.getId());
            stmt.setLong(11, p.getEstudianteId()); // Garantiza que solo el dueño edita
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[PortafolioDAO] Error al actualizar proyecto: " + e.getMessage());
        }
        return false;
    }

    public boolean eliminarProyecto(Long id, Long estudianteId) {
        String sql = "DELETE FROM portafolio_proyectos WHERE id = ? AND estudiante_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            stmt.setLong(2, estudianteId); // Garantiza que solo el dueño elimina
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[PortafolioDAO] Error al eliminar proyecto: " + e.getMessage());
        }
        return false;
    }

    // ----------------------------------------------------------------
    // HELPER
    // ----------------------------------------------------------------

    private PortafolioProyecto mapRow(ResultSet rs) throws SQLException {
        return new PortafolioProyecto(
            rs.getLong("id"),
            rs.getLong("estudiante_id"),
            rs.getString("titulo"),
            rs.getString("descripcion"),
            rs.getString("tecnologias"),
            rs.getString("url_demo"),
            rs.getString("url_repositorio"),
            rs.getString("imagen_preview"),
            rs.getString("categoria"),
            rs.getBoolean("destacado"),
            rs.getInt("orden"),
            rs.getString("fecha_creacion"),
            rs.getString("fecha_actualizacion")
        );
    }
}
