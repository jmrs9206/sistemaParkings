package com.jmrs.gestionparkings.model;

import jakarta.persistence.*;
import java.time.ZonedDateTime;
import java.util.List;

@Entity
@Table(name = "ABONADOS")
public class Abonado {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idAbonado;

    @Column(name = "nombre_razon_social", nullable = false)
    private String nombreRazonSocial;

    @Column(name = "dni_cif", nullable = false, unique = true)
    private String dniCif;

    @Column(nullable = false, unique = true)
    private String email;

    private String telefono;

    @Column(name = "id_localidad", nullable = false)
    private Integer idLocalidad;

    private Boolean activo = true;

    @Column(name = "created_at", insertable = false, updatable = false)
    private ZonedDateTime createdAt;

    @OneToMany(mappedBy = "abonado")
    private List<DatosPagoAbonado> metodosPago;

    // Getters and Setters
    public Integer getIdAbonado() { return idAbonado; }
    public void setIdAbonado(Integer idAbonado) { this.idAbonado = idAbonado; }
    public String getNombreRazonSocial() { return nombreRazonSocial; }
    public void setNombreRazonSocial(String nombreRazonSocial) { this.nombreRazonSocial = nombreRazonSocial; }
    public String getDniCif() { return dniCif; }
    public void setDniCif(String dniCif) { this.dniCif = dniCif; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }
    public Integer getIdLocalidad() { return idLocalidad; }
    public void setIdLocalidad(Integer idLocalidad) { this.idLocalidad = idLocalidad; }
    public Boolean getActivo() { return activo; }
    public void setActivo(Boolean activo) { this.activo = activo; }
    public ZonedDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(ZonedDateTime createdAt) { this.createdAt = createdAt; }
    public List<DatosPagoAbonado> getMetodosPago() { return metodosPago; }
    public void setMetodosPago(List<DatosPagoAbonado> metodosPago) { this.metodosPago = metodosPago; }
}
