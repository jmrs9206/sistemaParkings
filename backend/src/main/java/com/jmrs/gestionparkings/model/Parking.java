package com.jmrs.gestionparkings.model;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.ZonedDateTime;
import java.util.List;

@Entity
@Table(name = "PARKINGS")
public class Parking {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idParking;

    @Column(nullable = false, unique = true)
    private String nombre;

    @Column(name = "id_localidad", nullable = false)
    private Integer idLocalidad;

    private Boolean activo = true;

    @Column(name = "fecha_baja")
    private LocalDate fechaBaja;

    @Column(name = "created_at", insertable = false, updatable = false)
    private ZonedDateTime createdAt;

    @OneToMany(mappedBy = "parking", cascade = CascadeType.ALL)
    private List<Zona> zonas;

    // Getters and Setters
    public Integer getIdParking() { return idParking; }
    public void setIdParking(Integer idParking) { this.idParking = idParking; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public Integer getIdLocalidad() { return idLocalidad; }
    public void setIdLocalidad(Integer idLocalidad) { this.idLocalidad = idLocalidad; }
    public Boolean getActivo() { return activo; }
    public void setActivo(Boolean activo) { this.activo = activo; }
    public LocalDate getFechaBaja() { return fechaBaja; }
    public void setFechaBaja(LocalDate fechaBaja) { this.fechaBaja = fechaBaja; }
    public ZonedDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(ZonedDateTime createdAt) { this.createdAt = createdAt; }
    public List<Zona> getZonas() { return zonas; }
    public void setZonas(List<Zona> zonas) { this.zonas = zonas; }
}
