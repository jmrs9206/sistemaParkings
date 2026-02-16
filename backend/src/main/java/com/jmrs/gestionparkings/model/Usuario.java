package com.jmrs.gestionparkings.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Entidad que representa las credenciales de acceso de un usuario al sistema.
 * Vincula un código de abonado con una contraseña para el inicio de sesión.
 * Sigue el patrón MVC como parte de la capa de Modelo.
 * 
 * @author JMRS
 * @version 14.1
 */
@Entity
@Table(name = "USUARIOS")
public class Usuario {

    /**
     * Identificador único del usuario.
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idUsuario;

    /**
     * Nombre de usuario único, habitualmente coincide con el código de abonado.
     */
    @Column(name = "username", unique = true, nullable = false)
    private String username;

    /**
     * Contraseña de acceso (Almacenada en texto plano para este proyecto académico, 
     * se recomienda hashing en producción).
     */
    @Column(nullable = false)
    private String password;

    /**
     * Vínculo con los datos personales del abonado.
     */
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_abonado", nullable = false)
    private Abonado abonado;

    /**
     * Estado de la cuenta de usuario.
     */
    private Boolean activo = true;

    /**
     * Fecha de creación del usuario.
     */
    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    // Getters y Setters

    /** @return ID Usuario */
    public Integer getIdUsuario() { return idUsuario; }
    /** @param idUsuario ID a establecer */
    public void setIdUsuario(Integer idUsuario) { this.idUsuario = idUsuario; }

    /** @return Nombre de usuario */
    public String getUsername() { return username; }
    /** @param username Nombre a establecer */
    public void setUsername(String username) { this.username = username; }

    /** @return Contraseña */
    public String getPassword() { return password; }
    /** @param password Contraseña a establecer */
    public void setPassword(String password) { this.password = password; }

    /** @return Abonado asociado */
    public Abonado getAbonado() { return abonado; }
    /** @param abonado Abonado a establecer */
    public void setAbonado(Abonado abonado) { this.abonado = abonado; }

    /** @return Estado activo */
    public Boolean getActivo() { return activo; }
    /** @param activo Estado a establecer */
    public void setActivo(Boolean activo) { this.activo = activo; }

    /** @return Fecha de creación */
    public LocalDateTime getCreatedAt() { return createdAt; }
    /** @param createdAt Fecha a establecer */
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
