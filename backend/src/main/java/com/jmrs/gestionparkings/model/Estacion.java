package com.jmrs.gestionparkings.model;

import jakarta.persistence.*;
import java.time.ZonedDateTime;

@Entity
@Table(name = "ESTACIONES")
public class Estacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idEstacion;

    @Column(name = "codigo_estacion", nullable = false, unique = true)
    private String codigoEstacion;

    @Column(name = "id_sensor", nullable = false, unique = true)
    private String idSensor;

    @Column(name = "estado_actual", length = 1)
    private String estadoActual; // 'L', 'O', 'M'

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_zona", nullable = false)
    private Zona zona;

    @Column(name = "created_at", insertable = false, updatable = false)
    private ZonedDateTime createdAt;

    // Getters and Setters
    public Integer getIdEstacion() { return idEstacion; }
    public void setIdEstacion(Integer idEstacion) { this.idEstacion = idEstacion; }
    public String getCodigoEstacion() { return codigoEstacion; }
    public void setCodigoEstacion(String codigoEstacion) { this.codigoEstacion = codigoEstacion; }
    public String getIdSensor() { return idSensor; }
    public void setIdSensor(String idSensor) { this.idSensor = idSensor; }
    public String getEstadoActual() { return estadoActual; }
    public void setEstadoActual(String estadoActual) { this.estadoActual = estadoActual; }
    public Zona getZona() { return zona; }
    public void setZona(Zona zona) { this.zona = zona; }
    public ZonedDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(ZonedDateTime createdAt) { this.createdAt = createdAt; }
}
