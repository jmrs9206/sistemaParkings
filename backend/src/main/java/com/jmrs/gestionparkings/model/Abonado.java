package com.jmrs.gestionparkings.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Entidad que representa a un Cliente Abonado en el sistema.
 * El abonado es un cliente recurrente que posee un contrato y puede tener
 * múltiples vehículos asociados (matrícula principal y secundarias).
 * Parte de la capa de Modelo (Entidad de Datos).
 * 
 * @author JMRS
 * @version 14.1
 */
@Entity
@Table(name = "ABONADOS")
public class Abonado {

    /**
     * Identificador único autoincremental del abonado.
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idAbonado;

    /**
     * Nombre completo o razón social del cliente.
     */
    @Column(name = "nombre_razon_social", nullable = false)
    private String nombreRazonSocial;

    /**
     * Documento Nacional de Identidad o Identificador Fiscal.
     */
    @Column(name = "dni_cif", unique = true, nullable = false)
    private String dniCif;

    /**
     * Correo electrónico de contacto.
     */
    @Column(unique = true, nullable = false)
    private String email;

    /**
     * Teléfono de contacto.
     */
    private String telefono;

    /**
     * Identificador de la localidad de residencia.
     */
    @Column(name = "id_localidad", nullable = false)
    private Integer idLocalidad;

    /**
     * Identificador del parking al que se asocia el abonado.
     */
    @Column(name = "id_parking")
    private Integer idParking;

    /**
     * Matrícula principal autorizada en el contrato.
     */
    @Column(name = "matricula_principal")
    private String matriculaPrincipal;

    /**
     * Matrícula secundaria opcional autorizada.
     */
    @Column(name = "matricula_secundaria_1")
    private String matriculaSecundaria1;

    /**
     * Segunda matrícula secundaria opcional autorizada.
     */
    @Column(name = "matricula_secundaria_2")
    private String matriculaSecundaria2;

    /**
     * Código único de abonado (ej. PHX-0001). 
     * Se genera automáticamente tras la firma del contrato.
     */
    @Column(name = "codigo_abonado", unique = true)
    private String codigoAbonado;

    /**
     * Estado operativo del abonado.
     */
    private Boolean activo = true;

    /**
     * Sello de tiempo de alta en el sistema.
     */
    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    // Getters y Setters con Javadoc

    /** @return Identificador del abonado */
    public Integer getIdAbonado() { return idAbonado; }
    /** @param idAbonado Identificador a establecer */
    public void setIdAbonado(Integer idAbonado) { this.idAbonado = idAbonado; }

    /** @return Nombre del abonado */
    public String getNombreRazonSocial() { return nombreRazonSocial; }
    /** @param nombreRazonSocial Nombre a establecer */
    public void setNombreRazonSocial(String nombreRazonSocial) { this.nombreRazonSocial = nombreRazonSocial; }

    /** @return DNI/CIF */
    public String getDniCif() { return dniCif; }
    /** @param dniCif DNI a establecer */
    public void setDniCif(String dniCif) { this.dniCif = dniCif; }

    /** @return Email */
    public String getEmail() { return email; }
    /** @param email Email a establecer */
    public void setEmail(String email) { this.email = email; }

    /** @return Teléfono */
    public String getTelefono() { return telefono; }
    /** @param telefono Teléfono a establecer */
    public void setTelefono(String telefono) { this.telefono = telefono; }

    /** @return ID Localidad */
    public Integer getIdLocalidad() { return idLocalidad; }
    /** @param idLocalidad ID Localidad a establecer */
    public void setIdLocalidad(Integer idLocalidad) { this.idLocalidad = idLocalidad; }

    /** @return Matrícula principal */
    public String getMatriculaPrincipal() { return matriculaPrincipal; }
    /** @param matriculaPrincipal Matrícula a establecer */
    public void setMatriculaPrincipal(String matriculaPrincipal) { this.matriculaPrincipal = matriculaPrincipal; }

    /** @return Matrícula secundaria 1 */
    public String getMatriculaSecundaria1() { return matriculaSecundaria1; }
    /** @param matriculaSecundaria1 Matrícula a establecer */
    public void setMatriculaSecundaria1(String matriculaSecundaria1) { this.matriculaSecundaria1 = matriculaSecundaria1; }

    /** @return Matrícula secundaria 2 */
    public String getMatriculaSecundaria2() { return matriculaSecundaria2; }
    /** @param matriculaSecundaria2 Matrícula a establecer */
    public void setMatriculaSecundaria2(String matriculaSecundaria2) { this.matriculaSecundaria2 = matriculaSecundaria2; }

    /** @return Estado activo */
    public Boolean getActivo() { return activo; }
    /** @param activo Estado a establecer */
    public void setActivo(Boolean activo) { this.activo = activo; }

    /** @return Fecha de creación */
    public LocalDateTime getCreatedAt() { return createdAt; }
    /** @param createdAt Fecha a establecer */
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    /** @return ID del parking asociado */
    public Integer getIdParking() { return idParking; }
    /** @param idParking ID a establecer */
    public void setIdParking(Integer idParking) { this.idParking = idParking; }
}
