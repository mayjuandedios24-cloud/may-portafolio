package com.example.demo.model;

import java.io.Serializable;

/**
 * Modelo: Proyecto del portafolio web del estudiante.
 * Cada estudiante puede registrar, editar y actualizar
 * sus proyectos personales mostrados en su portafolio.
 */
public class PortafolioProyecto implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long   id;
    private Long   estudianteId;
    private String titulo;
    private String descripcion;
    private String tecnologias;      // Ej: "Java, JSP, MySQL, Tomcat"
    private String urlDemo;          // URL de la app desplegada en producción
    private String urlRepositorio;   // GitHub / GitLab
    private String imagenPreview;    // Ruta de imagen del proyecto
    private String categoria;        // Aplicación Web | API REST | Móvil | Escritorio
    private boolean destacado;       // Proyecto destacado en el portafolio
    private int    orden;            // Orden de visualización
    private String fechaCreacion;
    private String fechaActualizacion;

    public PortafolioProyecto() {}

    public PortafolioProyecto(Long id, Long estudianteId, String titulo, String descripcion,
                               String tecnologias, String urlDemo, String urlRepositorio,
                               String imagenPreview, String categoria, boolean destacado,
                               int orden, String fechaCreacion, String fechaActualizacion) {
        this.id                  = id;
        this.estudianteId        = estudianteId;
        this.titulo              = titulo;
        this.descripcion         = descripcion;
        this.tecnologias         = tecnologias;
        this.urlDemo             = urlDemo;
        this.urlRepositorio      = urlRepositorio;
        this.imagenPreview       = imagenPreview;
        this.categoria           = categoria;
        this.destacado           = destacado;
        this.orden               = orden;
        this.fechaCreacion       = fechaCreacion;
        this.fechaActualizacion  = fechaActualizacion;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getEstudianteId() { return estudianteId; }
    public void setEstudianteId(Long estudianteId) { this.estudianteId = estudianteId; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getTecnologias() { return tecnologias; }
    public void setTecnologias(String tecnologias) { this.tecnologias = tecnologias; }

    public String getUrlDemo() { return urlDemo; }
    public void setUrlDemo(String urlDemo) { this.urlDemo = urlDemo; }

    public String getUrlRepositorio() { return urlRepositorio; }
    public void setUrlRepositorio(String urlRepositorio) { this.urlRepositorio = urlRepositorio; }

    public String getImagenPreview() { return imagenPreview; }
    public void setImagenPreview(String imagenPreview) { this.imagenPreview = imagenPreview; }

    public String getCategoria() { return categoria != null ? categoria : "Aplicación Web"; }
    public void setCategoria(String categoria) { this.categoria = categoria; }

    public boolean isDestacado() { return destacado; }
    public void setDestacado(boolean destacado) { this.destacado = destacado; }

    public int getOrden() { return orden; }
    public void setOrden(int orden) { this.orden = orden; }

    public String getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(String fechaCreacion) { this.fechaCreacion = fechaCreacion; }

    public String getFechaActualizacion() { return fechaActualizacion; }
    public void setFechaActualizacion(String fechaActualizacion) { this.fechaActualizacion = fechaActualizacion; }

    public boolean tieneDemo() {
        return urlDemo != null && !urlDemo.trim().isEmpty();
    }
    public boolean isTieneDemo() { return tieneDemo(); }
    public boolean getTieneDemo() { return tieneDemo(); }

    public boolean tieneRepositorio() {
        return urlRepositorio != null && !urlRepositorio.trim().isEmpty();
    }
    public boolean isTieneRepositorio() { return tieneRepositorio(); }
    public boolean getTieneRepositorio() { return tieneRepositorio(); }
}
