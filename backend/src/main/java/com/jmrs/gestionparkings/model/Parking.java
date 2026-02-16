package com.jmrs.gestionparkings.model;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.ZonedDateTime;
import java.util.List;

/**
 * Entidad que representa un Parking físico en el sistema.
 * Contiene información sobre su ubicación, estado y zonas internas.
 * 
 * @author JMRS
 * @version 14.1
 */
@Entity
@Table(name = "PARKINGS")
public class Parking {

    /**
     * Identificador único del parking.
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idParking;

    /**
     * Nombre descriptivo del parking (ej. Parking Central).
     */
    @Column(nullable = false, unique = true)
    private String nombre;

    /**
     * Referencia a la localidad donde se ubica.
     */
    @Column(name = "id_localidad", nullable = false)
    private Integer idLocalidad;

    /**
     * Indica si el parking está operativo.
     */
    private Boolean activo = true;

    /**
     * Fecha en la que el parking cesó su actividad (si aplica).
     */
    @Column(name = "fecha_baja")
    private LocalDate fechaBaja;

    /**
     * Fecha y hora de registro en el sistema.
     */
    @Column(name = "created_at", insertable = false, updatable = false)
    private ZonedDateTime createdAt;

    /**
     * Listado de zonas (plantas, secciones) que componen el parking.
     */
    @OneToMany(mappedBy = "parking", cascade = CascadeType.ALL)
    private List<Zona> zonas;

    // Getters y Setters con Javadoc

    /** @return ID del parking */
    public Integer getIdParking() { return idParking; }
    /** @param idParking ID a establecer */
    public void setIdParking(Integer idParking) { this.idParking = idParking; }

    /** @return Nombre del parking */
    public String getNombre() { return nombre; }
    /** @param nombre Nombre a establecer */
    public void setNombre(String nombre) { this.nombre = nombre; }

    /** @return ID de localidad */
    public Integer getIdLocalidad() { return idLocalidad; }
    /** @param idLocalidad ID a establecer */
    public void setIdLocalidad(Integer idLocalidad) { this.idLocalidad = idLocalidad; }

    /** @return Estado activo */
    public Boolean getActivo() { return activo; }
    /** @param activo Estado a establecer */
    public void setActivo(Boolean activo) { this.activo = activo; }

    /** @return Fecha de baja */
    public LocalDate getFechaBaja() { return fechaBaja; }
    /** @param fechaBaja Fecha a establecer */
    public void setFechaBaja(LocalDate fechaBaja) { this.fechaBaja = fechaBaja; }

    /** @return Fecha de registro */
    public ZonedDateTime getCreatedAt() { return createdAt; }
    /** @param createdAt Fecha a establecer */
    public void setCreatedAt(ZonedDateTime createdAt) { this.createdAt = createdAt; }

    /** @return Lista de zonas */
    public List<Zona> getZonas() { return zonas; }
    /** @param zonas Lista a establecer */
    public void setZonas(List<Zona> zonas) { this.zonas = zonas; }
}
