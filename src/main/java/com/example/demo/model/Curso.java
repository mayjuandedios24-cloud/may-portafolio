package com.example.demo.model;

import java.io.Serializable;

/**
 * Modelo: Curso académico.
 * El campo totalSemanas permite configurar dinámicamente la
 * cantidad de semanas del curso desde el panel del docente.
 */
public class Curso implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long   id;          // BIGINT en BD
    private String codigo;
    private String nombre;
    private String descripcion;
    private int    creditos;
    private String ciclo;
    private String icono;
    private int    totalSemanas; // Configurable por el docente (default 16)
    private Long   docenteId;
    private String docenteNombre;

    public Curso() {}

    public Curso(Long id, String codigo, String nombre, String descripcion,
                 int creditos, String ciclo, String icono, int totalSemanas,
                 Long docenteId, String docenteNombre) {
        this.id           = id;
        this.codigo       = codigo;
        this.nombre       = nombre;
        this.descripcion  = descripcion;
        this.creditos     = creditos;
        this.ciclo        = ciclo;
        this.icono        = icono;
        this.totalSemanas = totalSemanas;
        this.docenteId    = docenteId;
        this.docenteNombre= docenteNombre;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public int getCreditos() { return creditos; }
    public void setCreditos(int creditos) { this.creditos = creditos; }

    public String getCiclo() { return ciclo; }
    public void setCiclo(String ciclo) { this.ciclo = ciclo; }

    public String getIcono() { return icono != null ? icono : "fa-laptop-code"; }
    public void setIcono(String icono) { this.icono = icono; }

    public int getTotalSemanas() { return totalSemanas > 0 ? totalSemanas : 16; }
    public void setTotalSemanas(int totalSemanas) { this.totalSemanas = totalSemanas; }

    public Long getDocenteId() { return docenteId; }
    public void setDocenteId(Long docenteId) { this.docenteId = docenteId; }

    public String getDocenteNombre() { return docenteNombre; }
    public void setDocenteNombre(String docenteNombre) { this.docenteNombre = docenteNombre; }
}
