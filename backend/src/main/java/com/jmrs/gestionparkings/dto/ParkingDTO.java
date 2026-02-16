package com.jmrs.gestionparkings.dto;

import java.util.List;

public class ParkingDTO {
    private Integer idParking;
    private String nombre;
    private List<ZonaDTO> zonas;

    // Getters and Setters
    public Integer getIdParking() { return idParking; }
    public void setIdParking(Integer idParking) { this.idParking = idParking; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public List<ZonaDTO> getZonas() { return zonas; }
    public void setZonas(List<ZonaDTO> zonas) { this.zonas = zonas; }
}
