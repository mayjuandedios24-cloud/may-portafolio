package com.example.demo.model;

import java.io.Serializable;

/**
 * Modelo: Semana académica del curso.
 * numero es int (no String) para consistencia con la BD.
 */
public class Semana implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long   id;
    private Long   cursoId;
    private int    numero;      // INT en BD — tipo corregido de String a int
    private String titulo;
    private String descripcion;
    private String fechaLimite;

    public Semana() {}

    public Semana(int numero, String titulo, String descripcion) {
        this.numero      = numero;
        this.titulo      = titulo;
        this.descripcion = descripcion;
    }

    public Semana(Long id, Long cursoId, int numero, String titulo,
                  String descripcion, String fechaLimite) {
        this.id          = id;
        this.cursoId     = cursoId;
        this.numero      = numero;
        this.titulo      = titulo;
        this.descripcion = descripcion;
        this.fechaLimite = fechaLimite;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getCursoId() { return cursoId; }
    public void setCursoId(Long cursoId) { this.cursoId = cursoId; }

    public int getNumero() { return numero; }
    public void setNumero(int numero) { this.numero = numero; }

    /** Conveniencia para JSTL/EL que espera String en algunos contextos */
    public String getNumeroStr() { return String.valueOf(numero); }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getFechaLimite() { return fechaLimite; }
    public void setFechaLimite(String fechaLimite) { this.fechaLimite = fechaLimite; }
}
