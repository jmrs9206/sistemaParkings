package com.jmrs.gestionparkings.dto;

import java.util.List;

public class ZonaDTO {
    private Integer idZona;
    private String nombre;
    private List<EstacionDTO> estaciones;

    // Getters and Setters
    public Integer getIdZona() { return idZona; }
    public void setIdZona(Integer idZona) { this.idZona = idZona; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public List<EstacionDTO> getEstaciones() { return estaciones; }
    public void setEstaciones(List<EstacionDTO> estaciones) { this.estaciones = estaciones; }
}
