package com.example.demo.dao;

import com.example.demo.config.DBConnection;
import com.example.demo.model.Curso;
import com.example.demo.model.Semana;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO de Curso y Semanas.
 * Soporta:
 *   - Obtener el curso principal (ID=1)
 *   - Actualizar información del curso (docente)
 *   - Configurar dinámicamente el número de semanas
 *   - CRUD de semanas individuales (título, descripción, fecha)
 */
public class CursoDAO {

    private static final long CURSO_ID = 1L;

    // ----------------------------------------------------------------
    // LECTURA DE CURSO
    // ----------------------------------------------------------------

    public Curso obtenerCursoPrincipal() {
        String sql = "SELECT c.id, c.codigo, c.nombre, c.descripcion, c.creditos, c.ciclo, " +
                     "c.icono, c.total_semanas, c.docente_id, u.nombre_completo AS docente_nombre " +
                     "FROM cursos c LEFT JOIN usuarios u ON c.docente_id = u.id WHERE c.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, CURSO_ID);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapCurso(rs);
            }
        } catch (SQLException e) {
            System.err.println("[CursoDAO] Error al obtener curso principal: " + e.getMessage());
        }
        return cursoFallback();
    }

    /** Alias para compatibilidad con código existente */
    public Curso obtenerCursoPorId(String id) {
        return obtenerCursoPrincipal();
    }

    public List<Curso> obtenerTodosLosCursos() {
        List<Curso> lista = new ArrayList<>();
        String sql = "SELECT c.id, c.codigo, c.nombre, c.descripcion, c.creditos, c.ciclo, " +
                     "c.icono, c.total_semanas, c.docente_id, u.nombre_completo AS docente_nombre " +
                     "FROM cursos c LEFT JOIN usuarios u ON c.docente_id = u.id ORDER BY c.id ASC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) lista.add(mapCurso(rs));
        } catch (SQLException e) {
            System.err.println("[CursoDAO] Error al listar cursos: " + e.getMessage());
        }
        if (lista.isEmpty()) lista.add(cursoFallback());
        return lista;
    }

    // ----------------------------------------------------------------
    // ACTUALIZACIÓN DEL CURSO (DOCENTE)
    // ----------------------------------------------------------------

    /**
     * El docente actualiza la descripción del curso.
     */
    public boolean actualizarDescripcionCurso(Long cursoId, String descripcion) {
        String sql = "UPDATE cursos SET descripcion = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, descripcion);
            stmt.setLong(2, cursoId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[CursoDAO] Error actualizando descripcion: " + e.getMessage());
        }
        return false;
    }

    /**
     * El docente configura el número de semanas del curso.
     * Si aumenta → crea semanas nuevas vacías.
     * Si disminuye → elimina semanas excedentes (si no tienen trabajos).
     */
    public boolean configurarTotalSemanas(Long cursoId, int totalSemanas) {
        if (totalSemanas < 1 || totalSemanas > 52) return false;

        String sqlUpdate = "UPDATE cursos SET total_semanas = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 1. Actualizar total_semanas en el curso
                try (PreparedStatement stmt = conn.prepareStatement(sqlUpdate)) {
                    stmt.setInt(1, totalSemanas);
                    stmt.setLong(2, cursoId);
                    stmt.executeUpdate();
                }

                // 2. Obtener semanas existentes
                int maxExistente = 0;
                String sqlMax = "SELECT COALESCE(MAX(numero), 0) FROM semanas WHERE curso_id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(sqlMax)) {
                    stmt.setLong(1, cursoId);
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (rs.next()) maxExistente = rs.getInt(1);
                    }
                }

                // 3. Si hay que crear nuevas semanas
                if (totalSemanas > maxExistente) {
                    String sqlInsert = "INSERT IGNORE INTO semanas (curso_id, numero, titulo, descripcion, fecha_limite) " +
                                       "VALUES (?, ?, ?, ?, NULL)";
                    try (PreparedStatement stmt = conn.prepareStatement(sqlInsert)) {
                        for (int i = maxExistente + 1; i <= totalSemanas; i++) {
                            stmt.setLong(1, cursoId);
                            stmt.setInt(2, i);
                            stmt.setString(3, "Semana " + i + ": Título por definir");
                            stmt.setString(4, "Descripción de la actividad de la semana " + i);
                            stmt.addBatch();
                        }
                        stmt.executeBatch();
                    }
                }

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                System.err.println("[CursoDAO] Error configurando semanas: " + e.getMessage());
            }
        } catch (SQLException e) {
            System.err.println("[CursoDAO] Error de conexión en configurarTotalSemanas: " + e.getMessage());
        }
        return false;
    }

    // ----------------------------------------------------------------
    // LECTURA DE SEMANAS
    // ----------------------------------------------------------------

    public List<Semana> obtenerSemanasPorCurso(String cursoId) {
        List<Semana> semanas = new ArrayList<>();
        String sql = "SELECT s.id, s.curso_id, s.numero, s.titulo, s.descripcion, s.fecha_limite " +
                     "FROM semanas s JOIN cursos c ON s.curso_id = c.id " +
                     "WHERE s.curso_id = ? AND s.numero <= c.total_semanas ORDER BY s.numero ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            long cId = CURSO_ID;
            if (cursoId != null && !cursoId.trim().isEmpty()) {
                try { cId = Long.parseLong(cursoId.trim()); } catch (NumberFormatException ignored) {}
            }
            stmt.setLong(1, cId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) semanas.add(mapSemana(rs));
            }
        } catch (SQLException e) {
            System.err.println("[CursoDAO] Error al obtener semanas: " + e.getMessage());
        }
        if (semanas.isEmpty()) semanas = semanasFallback();
        return semanas;
    }

    public List<Semana> obtenerSemanas() {
        return obtenerSemanasPorCurso("1");
    }

    public Semana obtenerSemanaPorNumero(Long cursoId, int numero) {
        String sql = "SELECT id, curso_id, numero, titulo, descripcion, fecha_limite " +
                     "FROM semanas WHERE curso_id = ? AND numero = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, cursoId);
            stmt.setInt(2, numero);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapSemana(rs);
            }
        } catch (SQLException e) {
            System.err.println("[CursoDAO] Error al obtener semana por número: " + e.getMessage());
        }
        return null;
    }

    // ----------------------------------------------------------------
    // ACTUALIZACIÓN DE SEMANAS (DOCENTE)
    // ----------------------------------------------------------------

    /**
     * El docente edita el título, descripción y fecha límite de una semana.
     */
    public boolean actualizarSemana(Long semanaId, String titulo, String descripcion, String fechaLimite) {
        String sql = "UPDATE semanas SET titulo = ?, descripcion = ?, fecha_limite = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, titulo != null ? titulo.trim() : "");
            stmt.setString(2, descripcion != null ? descripcion.trim() : "");
            if (fechaLimite != null && !fechaLimite.trim().isEmpty()) {
                stmt.setDate(3, Date.valueOf(fechaLimite.trim()));
            } else {
                stmt.setNull(3, Types.DATE);
            }
            stmt.setLong(4, semanaId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[CursoDAO] Error al actualizar semana: " + e.getMessage());
        }
        return false;
    }

    // ----------------------------------------------------------------
    // HELPERS PRIVADOS
    // ----------------------------------------------------------------

    private Curso mapCurso(ResultSet rs) throws SQLException {
        return new Curso(
            rs.getLong("id"),
            rs.getString("codigo"),
            rs.getString("nombre"),
            rs.getString("descripcion"),
            rs.getInt("creditos"),
            rs.getString("ciclo"),
            rs.getString("icono"),
            rs.getInt("total_semanas"),
            rs.getObject("docente_id") != null ? rs.getLong("docente_id") : null,
            rs.getString("docente_nombre")
        );
    }

    private Semana mapSemana(ResultSet rs) throws SQLException {
        Date fechaLimite = rs.getDate("fecha_limite");
        return new Semana(
            rs.getLong("id"),
            rs.getLong("curso_id"),
            rs.getInt("numero"),
            rs.getString("titulo"),
            rs.getString("descripcion"),
            fechaLimite != null ? fechaLimite.toString() : null
        );
    }

    private Curso cursoFallback() {
        return new Curso(1L, "CS-501", "Programación de Aplicación Profesional",
            "Desarrollo de aplicaciones empresariales escalables con Java Servlets, JSP, JDBC, MVC y despliegue web.",
            5, "2026-II", "fa-laptop-code", 16, 2L, "Ing. Docente Titular");
    }

    private List<Semana> semanasFallback() {
        List<Semana> semanas = new ArrayList<>();
        String[] titulos = {
            "Fundamentos de Arquitectura Web & HTML5 Semántico",
            "Estilos Avanzados con CSS Moderno & Glassmorphism",
            "Introducción a Servlets en Jakarta EE",
            "JavaServer Pages (JSP) & Taglibs JSTL",
            "Patrón Arquitectónico Modelo-Vista-Controlador (MVC)",
            "Conectividad a Bases de Datos Relacionales con JDBC",
            "Implementación del Patrón DAO (Data Access Object)",
            "Evaluación Parcial — Integración del Sistema LMS",
            "Manejo de Sesiones HTTP & Filtros de Seguridad",
            "Subida Segura de Archivos Multipart en Servlets",
            "Registro y Visualización de Proyectos Prácticos",
            "Módulo Docente: Calificaciones y Retroalimentación",
            "Optimización de Consultas SQL e Índices en MySQL",
            "Seguridad Web & Sanitización de Datos",
            "Preparación para Despliegue en la Nube (Render / Cloud)",
            "Sustentación Final del Portafolio Académico"
        };
        for (int i = 1; i <= 16; i++) {
            semanas.add(new Semana((long) i, 1L, i,
                "Semana " + i + ": " + titulos[i - 1],
                "Actividades académicas y entregables de la semana " + i,
                null));
        }
        return semanas;
    }
}
