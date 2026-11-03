package com.example.demo.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class PortafolioConfig implements Serializable {

    private Long id;
    private Long estudianteId;
    private String heroNombre;
    private String heroTitulo;
    private String heroFrases;
    private String heroDescripcion;
    private String heroImagen;
    private String githubUrl;
    private String linkedinUrl;
    private String instagramUrl;
    private String whatsappNumero;

    private String aboutTitulo;
    private String aboutDescripcion;
    private String aboutFilosofia;
    private String aboutMision;
    private String aboutImagen;

    private String educacionData;
    private String habilidadesData;

    public PortafolioConfig() {
        this.heroNombre = "MAYLIN ZAMUDIO";
        this.heroTitulo = "Hola, soy MAYLIN";
        this.heroFrases = "Ingeniera de Software, Desarrolladora Full Stack Java, Creadora de Experiencias Web";
        this.heroDescripcion = "Desarrolladora de software apasionada por transformar conceptos complejos en experiencias web interactivas, seguras y de alto rendimiento. Especializada en Java, Jakarta Servlets, JSP, JDBC, MySQL y Arquitectura MVC.";
        this.heroImagen = "assets/img/Img_May.jpeg";
        this.githubUrl = "https://github.com";
        this.linkedinUrl = "https://linkedin.com";
        this.instagramUrl = "https://instagram.com";
        this.whatsappNumero = "51952374069";

        this.aboutTitulo = "Sobre Mí";
        this.aboutDescripcion = "Desarrollo de experiencias web y sistemas académicos de alto impacto a través de código estructurado, diseño responsivo y arquitectura modular.";
        this.aboutFilosofia = "Combinar la disciplina técnica con un diseño de interfaz intuitivo y estilizado, garantizando código mantenible, libre de vulnerabilidades y de alto rendimiento.";
        this.aboutMision = "Construir plataformas educativas y soluciones empresariales con arquitectura robusta en Java, facilitando la gestión de evidencias, código fuente y aplicaciones desplegadas.";
        this.aboutImagen = "assets/img/sakura_fan.jpg";

        this.educacionData = "Programación de Aplicación Profesional | Instituto Andres A. Caceres D. • Ciclo 2026-II | Enfoque en Arquitectura MVC, Servlets, JSP y JDBC\n" +
                "Desarrollo de Aplicaciones Web y Gestión de Datos | Ecosistema Java Empresarial, MySQL y Apache Tomcat | Modelado relacional, PreparedStatement y seguridad web\n" +
                "Diseño UI/UX y Desarrollo Frontend Cyber-Sakura | Interfaces Modernas con CSS3, Glassmorphism y Responsive Design | 2026";

        this.habilidadesData = "Java 21 & Jakarta Servlets (MVC) | 95\n" +
                "JavaServer Pages (JSP) & JSTL | 92\n" +
                "HTML5 / CSS3 / Glassmorphism | 90\n" +
                "MySQL & MySQL Workbench (JDBC) | 92\n" +
                "Apache Tomcat 10 & Despliegue Cloud | 88\n" +
                "Gestión de Repositorios & Git/GitHub | 90";
    }

    // Clases estáticas para representar Educación y Habilidades estructuradas
    public static class EducacionItem {
        private String titulo;
        private String institucion;
        private String periodo;

        public EducacionItem(String titulo, String institucion, String periodo) {
            this.titulo = titulo;
            this.institucion = institucion;
            this.periodo = periodo;
        }

        public String getTitulo() { return titulo; }
        public String getInstitucion() { return institucion; }
        public String getPeriodo() { return periodo; }
    }

    public static class HabilidadItem {
        private String nombre;
        private int porcentaje;

        public HabilidadItem(String nombre, int porcentaje) {
            this.nombre = nombre;
            this.porcentaje = porcentaje;
        }

        public String getNombre() { return nombre; }
        public int getPorcentaje() { return porcentaje; }
    }

    public List<EducacionItem> getListaEducacion() {
        List<EducacionItem> lista = new ArrayList<>();
        if (educacionData == null || educacionData.trim().isEmpty()) return lista;
        String[] lineas = educacionData.split("\\r?\\n");
        for (String linea : lineas) {
            String l = linea.trim();
            if (l.isEmpty()) continue;
            String[] partes = l.split("\\|");
            String titulo = partes.length > 0 ? partes[0].trim() : "";
            String inst = partes.length > 1 ? partes[1].trim() : "";
            String per = partes.length > 2 ? partes[2].trim() : "";
            lista.add(new EducacionItem(titulo, inst, per));
        }
        return lista;
    }

    public List<HabilidadItem> getListaHabilidades() {
        List<HabilidadItem> lista = new ArrayList<>();
        if (habilidadesData == null || habilidadesData.trim().isEmpty()) return lista;
        String[] lineas = habilidadesData.split("\\r?\\n");
        for (String linea : lineas) {
            String l = linea.trim();
            if (l.isEmpty()) continue;
            String[] partes = l.split("\\|");
            String nombre = partes.length > 0 ? partes[0].trim() : "";
            int porc = 85;
            if (partes.length > 1) {
                try {
                    String pStr = partes[1].replace("%", "").trim();
                    porc = Integer.parseInt(pStr);
                    if (porc < 0) porc = 0;
                    if (porc > 100) porc = 100;
                } catch (NumberFormatException ignored) {}
            }
            lista.add(new HabilidadItem(nombre, porc));
        }
        return lista;
    }

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getEstudianteId() { return estudianteId; }
    public void setEstudianteId(Long estudianteId) { this.estudianteId = estudianteId; }

    public String getHeroNombre() { return heroNombre; }
    public void setHeroNombre(String heroNombre) { this.heroNombre = heroNombre; }

    public String getHeroTitulo() { return heroTitulo; }
    public void setHeroTitulo(String heroTitulo) { this.heroTitulo = heroTitulo; }

    public String getHeroFrases() { return heroFrases; }
    public void setHeroFrases(String heroFrases) { this.heroFrases = heroFrases; }

    public String getHeroDescripcion() { return heroDescripcion; }
    public void setHeroDescripcion(String heroDescripcion) { this.heroDescripcion = heroDescripcion; }

    public String getHeroImagen() { return heroImagen; }
    public void setHeroImagen(String heroImagen) { this.heroImagen = heroImagen; }

    public String getGithubUrl() { return githubUrl; }
    public void setGithubUrl(String githubUrl) { this.githubUrl = githubUrl; }

    public String getLinkedinUrl() { return linkedinUrl; }
    public void setLinkedinUrl(String linkedinUrl) { this.linkedinUrl = linkedinUrl; }

    public String getInstagramUrl() { return instagramUrl; }
    public void setInstagramUrl(String instagramUrl) { this.instagramUrl = instagramUrl; }

    public String getWhatsappNumero() { return whatsappNumero; }
    public void setWhatsappNumero(String whatsappNumero) { this.whatsappNumero = whatsappNumero; }

    public String getAboutTitulo() { return aboutTitulo; }
    public void setAboutTitulo(String aboutTitulo) { this.aboutTitulo = aboutTitulo; }

    public String getAboutDescripcion() { return aboutDescripcion; }
    public void setAboutDescripcion(String aboutDescripcion) { this.aboutDescripcion = aboutDescripcion; }

    public String getAboutFilosofia() { return aboutFilosofia; }
    public void setAboutFilosofia(String aboutFilosofia) { this.aboutFilosofia = aboutFilosofia; }

    public String getAboutMision() { return aboutMision; }
    public void setAboutMision(String aboutMision) { this.aboutMision = aboutMision; }

    public String getAboutImagen() { return aboutImagen; }
    public void setAboutImagen(String aboutImagen) { this.aboutImagen = aboutImagen; }

    public String getEducacionData() { return educacionData; }
    public void setEducacionData(String educacionData) { this.educacionData = educacionData; }

    public String getHabilidadesData() { return habilidadesData; }
    public void setHabilidadesData(String habilidadesData) { this.habilidadesData = habilidadesData; }
}
