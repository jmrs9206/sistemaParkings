package com.jmrs.gestionparkings.model;

import jakarta.persistence.*;
import java.time.ZonedDateTime;

/**
 * Entidad que representa una plaza de aparcamiento individual (Estación).
 * Monitorizada mediante un sensor técnico.
 * 
 * @author JMRS
 * @version 14.1
 */
@Entity
@Table(name = "ESTACIONES")
public class Estacion {

    /**
     * Identificador único de la estación/plaza.
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idEstacion;

    /**
     * Código de identificación humano (ej. P1-23).
     */
    @Column(name = "codigo_estacion", nullable = false, unique = true)
    private String codigoEstacion;

    /**
     * Identificador técnico del hardware vinculado.
     */
    @Column(name = "id_sensor", nullable = false, unique = true)
    private String idSensor;

    /**
     * Estado actual de la plaza (L:Libre, O:Ocupada, M:Mantenimiento).
     */
    @Column(name = "estado_actual", length = 1)
    private String estadoActual;

    /**
     * Zona física a la que pertenece la plaza.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_zona", nullable = false)
    private Zona zona;

    /**
     * Fecha de alta de la estación.
     */
    @Column(name = "created_at", insertable = false, updatable = false)
    private ZonedDateTime createdAt;

    // Getters y Setters con Javadoc

    /** @return ID Estación */
    public Integer getIdEstacion() { return idEstacion; }
    /** @param idEstacion ID a establecer */
    public void setIdEstacion(Integer idEstacion) { this.idEstacion = idEstacion; }

    /** @return Código de estación */
    public String getCodigoEstacion() { return codigoEstacion; }
    /** @param codigoEstacion Código a establecer */
    public void setCodigoEstacion(String codigoEstacion) { this.codigoEstacion = codigoEstacion; }

    /** @return ID de sensor */
    public String getIdSensor() { return idSensor; }
    /** @param idSensor ID a establecer */
    public void setIdSensor(String idSensor) { this.idSensor = idSensor; }

    /** @return Estado actual */
    public String getEstadoActual() { return estadoActual; }
    /** @param estadoActual Estado a establecer */
    public void setEstadoActual(String estadoActual) { this.estadoActual = estadoActual; }

    /** @return Zona asociada */
    public Zona getZona() { return zona; }
    /** @param zona Zona a establecer */
    public void setZona(Zona zona) { this.zona = zona; }

    /** @return Fecha de registro */
    public ZonedDateTime getCreatedAt() { return createdAt; }
    /** @param createdAt Fecha a establecer */
    public void setCreatedAt(ZonedDateTime createdAt) { this.createdAt = createdAt; }
}
