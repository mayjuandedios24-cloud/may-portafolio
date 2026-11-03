package com.example.demo.model;

import java.io.Serializable;

/**
 * Modelo: Trabajo / Entrega académica del estudiante.
 * Soporta archivo físico (ZIP/RAR/PDF) y/o URL de proyecto desplegado.
 * semanaNumero es int para coherencia con BD.
 */
public class Trabajo implements Serializable {
    private static final long serialVersionUID = 1L;

    private String id;            // VARCHAR(50) — "T" + timestamp
    private Long   cursoId;       // BIGINT — siempre 1 en el sistema actual
    private Long   semanaId;      // FK → semanas.id (puede ser null)
    private int    semanaNumero;  // INT — número de semana (1..N)
    private Long   estudianteId;  // FK → usuarios.id
    private String estudianteNombre;
    private String titulo;
    private String descripcion;
    private String fechaEntrega;
    private String archivoNombre;   // Nombre del archivo físico en /uploads/
    private String urlProyecto;     // URL desplegada (Render / Netlify / GitHub Pages)
    private String estado;          // Pendiente | Entregado | En revisión | Calificado | Observado
    private String notaPersonal;
    private String categoriaTag;
    private String calificacion;    // Nota vigesimal: "18/20"
    private String observacionDocente;

    public Trabajo() {}

    public Trabajo(String id, Long cursoId, Long semanaId, int semanaNumero,
                   Long estudianteId, String estudianteNombre, String titulo,
                   String descripcion, String fechaEntrega, String archivoNombre,
                   String urlProyecto, String estado, String notaPersonal,
                   String categoriaTag, String calificacion, String observacionDocente) {
        this.id                 = id;
        this.cursoId            = cursoId;
        this.semanaId           = semanaId;
        this.semanaNumero       = semanaNumero;
        this.estudianteId       = estudianteId;
        this.estudianteNombre   = estudianteNombre;
        this.titulo             = titulo;
        this.descripcion        = descripcion;
        this.fechaEntrega       = fechaEntrega;
        this.archivoNombre      = archivoNombre;
        this.urlProyecto        = urlProyecto;
        this.estado             = estado;
        this.notaPersonal       = notaPersonal;
        this.categoriaTag       = categoriaTag;
        this.calificacion       = calificacion;
        this.observacionDocente = observacionDocente;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public Long getCursoId() { return cursoId; }
    public void setCursoId(Long cursoId) { this.cursoId = cursoId; }

    public Long getSemanaId() { return semanaId; }
    public void setSemanaId(Long semanaId) { this.semanaId = semanaId; }

    public int getSemanaNumero() { return semanaNumero; }
    public void setSemanaNumero(int semanaNumero) { this.semanaNumero = semanaNumero; }

    /** Conveniencia para JSTL que usa getSemanaNumeroStr() */
    public String getSemanaNumeroStr() { return String.valueOf(semanaNumero); }

    public Long getEstudianteId() { return estudianteId; }
    public void setEstudianteId(Long estudianteId) { this.estudianteId = estudianteId; }

    public String getEstudianteNombre() {
        return estudianteNombre != null ? estudianteNombre : "Estudiante";
    }
    public void setEstudianteNombre(String estudianteNombre) { this.estudianteNombre = estudianteNombre; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getFechaEntrega() { return fechaEntrega; }
    public void setFechaEntrega(String fechaEntrega) { this.fechaEntrega = fechaEntrega; }

    public String getArchivoNombre() { return archivoNombre; }
    public void setArchivoNombre(String archivoNombre) { this.archivoNombre = archivoNombre; }

    public String getUrlProyecto() { return urlProyecto; }
    public void setUrlProyecto(String urlProyecto) { this.urlProyecto = urlProyecto; }

    public String getEstado() { return estado != null ? estado : "Entregado"; }
    public void setEstado(String estado) { this.estado = estado; }

    public String getNotaPersonal() { return notaPersonal; }
    public void setNotaPersonal(String notaPersonal) { this.notaPersonal = notaPersonal; }

    public String getCategoriaTag() { return categoriaTag != null ? categoriaTag : "Proyecto"; }
    public void setCategoriaTag(String categoriaTag) { this.categoriaTag = categoriaTag; }

    public String getCalificacion() { return calificacion; }
    public void setCalificacion(String calificacion) { this.calificacion = calificacion; }

    public String getObservacionDocente() { return observacionDocente; }
    public void setObservacionDocente(String observacionDocente) { this.observacionDocente = observacionDocente; }

    /** Retorna true si el trabajo tiene un archivo físico subido */
    public boolean tieneArchivo() {
        return archivoNombre != null && !archivoNombre.trim().isEmpty();
    }
    public boolean isTieneArchivo() { return tieneArchivo(); }
    public boolean getTieneArchivo() { return tieneArchivo(); }

    /** Retorna true si el trabajo tiene URL de proyecto desplegado */
    public boolean tieneUrl() {
        return urlProyecto != null && !urlProyecto.trim().isEmpty();
    }
    public boolean isTieneUrl() { return tieneUrl(); }
    public boolean getTieneUrl() { return tieneUrl(); }
}
