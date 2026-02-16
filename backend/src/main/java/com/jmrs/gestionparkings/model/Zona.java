package com.jmrs.gestionparkings.model;

import jakarta.persistence.*;
import java.time.ZonedDateTime;
import java.util.List;

@Entity
@Table(name = "ZONAS")
public class Zona {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idZona;

    @Column(nullable = false)
    private String nombre;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_parking", nullable = false)
    private Parking parking;

    private Boolean activo = true;

    @Column(name = "created_at", insertable = false, updatable = false)
    private ZonedDateTime createdAt;

    @OneToMany(mappedBy = "zona", cascade = CascadeType.ALL)
    private List<Estacion> estaciones;

    // Getters and Setters
    public Integer getIdZona() { return idZona; }
    public void setIdZona(Integer idZona) { this.idZona = idZona; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public Parking getParking() { return parking; }
    public void setParking(Parking parking) { this.parking = parking; }
    public Boolean getActivo() { return activo; }
    public void setActivo(Boolean activo) { this.activo = activo; }
    public ZonedDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(ZonedDateTime createdAt) { this.createdAt = createdAt; }
    public List<Estacion> getEstaciones() { return estaciones; }
    public void setEstaciones(List<Estacion> estaciones) { this.estaciones = estaciones; }
}
