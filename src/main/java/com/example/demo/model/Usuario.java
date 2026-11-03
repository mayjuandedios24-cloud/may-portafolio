package com.example.demo.model;

import java.io.Serializable;

public class Usuario implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String username;
    private String password;
    private String nombreCompleto;
    private String email;
    private String rol; // "ESTUDIANTE" o "DOCENTE"
    private String avatar;

    public Usuario() {}

    public Usuario(Long id, String username, String password, String nombreCompleto, String email, String rol, String avatar) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.nombreCompleto = nombreCompleto;
        this.email = email;
        this.rol = rol;
        this.avatar = avatar;
    }

    public Usuario(Long id, String username, String password, String rol) {
        this(id, username, password, username, username + "@continental.edu.pe", rol, "assets/img/user.jpeg");
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getNombreCompleto() {
        return nombreCompleto != null ? nombreCompleto : username;
    }

    public void setNombreCompleto(String nombreCompleto) {
        this.nombreCompleto = nombreCompleto;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }

    public String getAvatar() {
        return avatar != null ? avatar : "assets/img/user.jpeg";
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }
}
