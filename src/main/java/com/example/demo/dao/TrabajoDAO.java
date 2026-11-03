package com.example.demo.dao;

import com.example.demo.config.DBConnection;
import com.example.demo.model.Trabajo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO de Trabajos / Entregas académicas.
 * Soporta CRUD completo: crear, leer (por curso, por semana, por ID),
 * actualizar, calificar (docente) y eliminar.
 * semanaNumero es INT en BD y en el modelo.
 */
public class TrabajoDAO {

    // ----------------------------------------------------------------
    // LECTURA
    // ----------------------------------------------------------------

    public List<Trabajo> obtenerTodos() {
        return ejecutarConsulta(
            "SELECT t.id, t.curso_id, t.semana_id, t.semana_numero, t.estudiante_id, " +
            "u.nombre_completo AS estudiante_nombre, t.titulo, t.descripcion, t.fecha_entrega, " +
            "t.archivo_nombre, t.url_proyecto, t.estado, t.nota_personal, t.categoria_tag, " +
            "t.calificacion, t.observacion_docente " +
            "FROM trabajos t LEFT JOIN usuarios u ON t.estudiante_id = u.id ORDER BY t.fecha_registro DESC",
            null
        );
    }

    public List<Trabajo> obtenerPorCurso(String cursoId) {
        return obtenerPorCursoLong(1L);
    }

    public List<Trabajo> obtenerPorCursoLong(Long cursoId) {
        String sql = "SELECT t.id, t.curso_id, t.semana_id, t.semana_numero, t.estudiante_id, " +
                     "u.nombre_completo AS estudiante_nombre, t.titulo, t.descripcion, t.fecha_entrega, " +
                     "t.archivo_nombre, t.url_proyecto, t.estado, t.nota_personal, t.categoria_tag, " +
                     "t.calificacion, t.observacion_docente " +
                     "FROM trabajos t LEFT JOIN usuarios u ON t.estudiante_id = u.id " +
                     "WHERE t.curso_id = ? ORDER BY t.semana_numero ASC, t.fecha_registro DESC";

        List<Trabajo> lista = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, cursoId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) lista.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[TrabajoDAO] Error en obtenerPorCurso: " + e.getMessage());
        }
        return lista;
    }

    public List<Trabajo> obtenerPorCursoYSemana(String cursoId, String semanaNumero) {
        if (semanaNumero == null || semanaNumero.trim().isEmpty()) semanaNumero = "1";
        int numSemana;
        try {
            numSemana = Integer.parseInt(semanaNumero.trim());
        } catch (NumberFormatException e) {
            return new ArrayList<>();
        }

        long cId = 1L;
        if (cursoId != null && !cursoId.trim().isEmpty()) {
            try { cId = Long.parseLong(cursoId.trim()); } catch (NumberFormatException ignored) {}
        }

        String sql = "SELECT t.id, t.curso_id, t.semana_id, t.semana_numero, t.estudiante_id, " +
                     "u.nombre_completo AS estudiante_nombre, t.titulo, t.descripcion, t.fecha_entrega, " +
                     "t.archivo_nombre, t.url_proyecto, t.estado, t.nota_personal, t.categoria_tag, " +
                     "t.calificacion, t.observacion_docente " +
                     "FROM trabajos t LEFT JOIN usuarios u ON t.estudiante_id = u.id " +
                     "WHERE t.curso_id = ? AND t.semana_numero = ? ORDER BY t.fecha_registro ASC";

        List<Trabajo> lista = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, cId);
            stmt.setInt(2, numSemana);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) lista.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[TrabajoDAO] Error en obtenerPorCursoYSemana: " + e.getMessage());
        }
        return lista;
    }

    public List<Trabajo> obtenerPorEstudiante(Long estudianteId) {
        String sql = "SELECT t.id, t.curso_id, t.semana_id, t.semana_numero, t.estudiante_id, " +
                     "u.nombre_completo AS estudiante_nombre, t.titulo, t.descripcion, t.fecha_entrega, " +
                     "t.archivo_nombre, t.url_proyecto, t.estado, t.nota_personal, t.categoria_tag, " +
                     "t.calificacion, t.observacion_docente " +
                     "FROM trabajos t LEFT JOIN usuarios u ON t.estudiante_id = u.id " +
                     "WHERE t.estudiante_id = ? ORDER BY t.semana_numero ASC, t.fecha_registro DESC";

        List<Trabajo> lista = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, estudianteId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) lista.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[TrabajoDAO] Error en obtenerPorEstudiante: " + e.getMessage());
        }
        return lista;
    }

    public Trabajo obtenerPorId(String id) {
        if (id == null || id.trim().isEmpty()) return null;
        String sql = "SELECT t.id, t.curso_id, t.semana_id, t.semana_numero, t.estudiante_id, " +
                     "u.nombre_completo AS estudiante_nombre, t.titulo, t.descripcion, t.fecha_entrega, " +
                     "t.archivo_nombre, t.url_proyecto, t.estado, t.nota_personal, t.categoria_tag, " +
                     "t.calificacion, t.observacion_docente " +
                     "FROM trabajos t LEFT JOIN usuarios u ON t.estudiante_id = u.id WHERE t.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, id.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[TrabajoDAO] Error en obtenerPorId: " + e.getMessage());
        }
        return null;
    }

    // ----------------------------------------------------------------
    // ESCRITURA
    // ----------------------------------------------------------------

    public boolean agregarTrabajo(Trabajo trabajo) {
        if (trabajo.getId() == null || trabajo.getId().isEmpty()) {
            trabajo.setId("T" + System.currentTimeMillis());
        }

        // Si no tiene semana_id, buscarlo dinámicamente en la tabla semanas
        if (trabajo.getSemanaId() == null) {
            String sqlSem = "SELECT id FROM semanas WHERE curso_id = ? AND numero = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement semStmt = conn.prepareStatement(sqlSem)) {
                semStmt.setLong(1, trabajo.getCursoId() != null ? trabajo.getCursoId() : 1L);
                semStmt.setInt(2, trabajo.getSemanaNumero());
                try (ResultSet rs = semStmt.executeQuery()) {
                    if (rs.next()) {
                        trabajo.setSemanaId(rs.getLong("id"));
                    }
                }
            } catch (SQLException ignored) {}
        }

        String sql = "INSERT INTO trabajos (id, curso_id, semana_id, semana_numero, estudiante_id, " +
                     "titulo, descripcion, fecha_entrega, archivo_nombre, url_proyecto, estado, " +
                     "nota_personal, categoria_tag, calificacion, observacion_docente) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, trabajo.getId());
            stmt.setLong(2, trabajo.getCursoId() != null ? trabajo.getCursoId() : 1L);
            if (trabajo.getSemanaId() != null) stmt.setLong(3, trabajo.getSemanaId());
            else stmt.setNull(3, Types.BIGINT);
            stmt.setInt(4, trabajo.getSemanaNumero());
            if (trabajo.getEstudianteId() != null) stmt.setLong(5, trabajo.getEstudianteId());
            else stmt.setNull(5, Types.BIGINT);
            stmt.setString(6, trabajo.getTitulo());
            stmt.setString(7, trabajo.getDescripcion());
            stmt.setString(8, trabajo.getFechaEntrega());
            stmt.setString(9, trabajo.getArchivoNombre());
            stmt.setString(10, trabajo.getUrlProyecto());
            stmt.setString(11, trabajo.getEstado());
            stmt.setString(12, trabajo.getNotaPersonal());
            stmt.setString(13, trabajo.getCategoriaTag());
            stmt.setString(14, trabajo.getCalificacion());
            stmt.setString(15, trabajo.getObservacionDocente());
            stmt.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("[TrabajoDAO] Error en agregarTrabajo: " + e.getMessage());
        }
        return false;
    }

    public boolean actualizarTrabajo(Trabajo t) {
        String sql = "UPDATE trabajos SET semana_numero = ?, titulo = ?, descripcion = ?, " +
                     "fecha_entrega = ?, archivo_nombre = ?, url_proyecto = ?, estado = ?, " +
                     "nota_personal = ?, categoria_tag = ?, calificacion = ?, observacion_docente = ? " +
                     "WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, t.getSemanaNumero());
            stmt.setString(2, t.getTitulo());
            stmt.setString(3, t.getDescripcion());
            stmt.setString(4, t.getFechaEntrega());
            stmt.setString(5, t.getArchivoNombre());
            stmt.setString(6, t.getUrlProyecto());
            stmt.setString(7, t.getEstado());
            stmt.setString(8, t.getNotaPersonal());
            stmt.setString(9, t.getCategoriaTag());
            stmt.setString(10, t.getCalificacion());
            stmt.setString(11, t.getObservacionDocente());
            stmt.setString(12, t.getId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[TrabajoDAO] Error en actualizarTrabajo: " + e.getMessage());
        }
        return false;
    }

    /**
     * El docente califica un trabajo: estado, nota vigesimal y observación.
     */
    public boolean actualizarCalificacionDocente(String id, String estado,
                                                  String calificacion, String observacionDocente) {
        String sql = "UPDATE trabajos SET estado = ?, calificacion = ?, observacion_docente = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, estado);
            stmt.setString(2, calificacion);
            stmt.setString(3, observacionDocente);
            stmt.setString(4, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[TrabajoDAO] Error en actualizarCalificacionDocente: " + e.getMessage());
        }
        return false;
    }

    public boolean eliminarTrabajo(String id) {
        String sql = "DELETE FROM trabajos WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[TrabajoDAO] Error en eliminarTrabajo: " + e.getMessage());
        }
        return false;
    }

    // ----------------------------------------------------------------
    // HELPERS PRIVADOS
    // ----------------------------------------------------------------

    private List<Trabajo> ejecutarConsulta(String sql, Object param) {
        List<Trabajo> lista = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement stmt;
            if (param != null) {
                stmt = conn.prepareStatement(sql);
                stmt.setObject(1, param);
            } else {
                stmt = conn.prepareStatement(sql);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) lista.add(mapRow(rs));
            }
            stmt.close();
        } catch (SQLException e) {
            System.err.println("[TrabajoDAO] Error en consulta: " + e.getMessage());
        }
        return lista;
    }

    private Trabajo mapRow(ResultSet rs) throws SQLException {
        return new Trabajo(
            rs.getString("id"),
            rs.getObject("curso_id") != null ? rs.getLong("curso_id") : 1L,
            rs.getObject("semana_id") != null ? rs.getLong("semana_id") : null,
            rs.getInt("semana_numero"),
            rs.getObject("estudiante_id") != null ? rs.getLong("estudiante_id") : null,
            rs.getString("estudiante_nombre"),
            rs.getString("titulo"),
            rs.getString("descripcion"),
            rs.getString("fecha_entrega"),
            rs.getString("archivo_nombre"),
            rs.getString("url_proyecto"),
            rs.getString("estado"),
            rs.getString("nota_personal"),
            rs.getString("categoria_tag"),
            rs.getString("calificacion"),
            rs.getString("observacion_docente")
        );
    }
}
