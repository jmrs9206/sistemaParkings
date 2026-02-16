package com.jmrs.gestionparkings.model;

import jakarta.persistence.*;
import java.time.ZonedDateTime;
import java.util.List;

/**
 * Entidad que representa una zona específica dentro de un parking (ej. Planta 1).
 * 
 * @author JMRS
 * @version 14.1
 */
@Entity
@Table(name = "ZONAS")
public class Zona {

    /**
     * Identificador único de la zona.
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idZona;

    /**
     * Nombre de la zona (ej. Planta Roja).
     */
    @Column(nullable = false)
    private String nombre;

    /**
     * Parking al que pertenece esta zona.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_parking", nullable = false)
    private Parking parking;

    /**
     * Indica si la zona está operativa.
     */
    private Boolean activo = true;

    /**
     * Fecha de registro de la zona.
     */
    @Column(name = "created_at", insertable = false, updatable = false)
    private ZonedDateTime createdAt;

    /**
     * Plazas de estacionamiento vinculadas a esta zona.
     */
    @OneToMany(mappedBy = "zona", cascade = CascadeType.ALL)
    private List<Estacion> estaciones;

    // Getters y Setters con Javadoc

    /** @return ID Zona */
    public Integer getIdZona() { return idZona; }
    /** @param idZona ID a establecer */
    public void setIdZona(Integer idZona) { this.idZona = idZona; }

    /** @return Nombre de la zona */
    public String getNombre() { return nombre; }
    /** @param nombre Nombre a establecer */
    public void setNombre(String nombre) { this.nombre = nombre; }

    /** @return Parking asociado */
    public Parking getParking() { return parking; }
    /** @param parking Parking a establecer */
    public void setParking(Parking parking) { this.parking = parking; }

    /** @return Estado activo */
    public Boolean getActivo() { return activo; }
    /** @param activo Estado a establecer */
    public void setActivo(Boolean activo) { this.activo = activo; }

    /** @return Fecha de registro */
    public ZonedDateTime getCreatedAt() { return createdAt; }
    /** @param createdAt Fecha a establecer */
    public void setCreatedAt(ZonedDateTime createdAt) { this.createdAt = createdAt; }

    /** @return Lista de estaciones */
    public List<Estacion> getEstaciones() { return estaciones; }
    /** @param estaciones Lista a establecer */
    public void setEstaciones(List<Estacion> estaciones) { this.estaciones = estaciones; }
}
