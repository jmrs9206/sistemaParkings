package com.jmrs.gestionparkings.dto;

import java.util.List;

/**
 * Objeto de Transferencia de Datos para representar un Parking.
 * 
 * @author JMRS
 * @version 14.1
 */
public class ParkingDTO {
    private Integer idParking;
    private String nombre;
    private Integer idLocalidad;
    private Boolean activo;
    private List<ZonaDTO> zonas;

    // Getters y Setters con Javadoc

    /** @return ID Parking */
    public Integer getIdParking() { return idParking; }
    /** @param idParking ID a establecer */
    public void setIdParking(Integer idParking) { this.idParking = idParking; }

    /** @return Nombre */
    public String getNombre() { return nombre; }
    /** @param nombre Nombre a establecer */
    public void setNombre(String nombre) { this.nombre = nombre; }

    /** @return ID Localidad */
    public Integer getIdLocalidad() { return idLocalidad; }
    /** @param idLocalidad ID a establecer */
    public void setIdLocalidad(Integer idLocalidad) { this.idLocalidad = idLocalidad; }

    /** @return Estado activo */
    public Boolean getActivo() { return activo; }
    /** @param activo Estado a establecer */
    public void setActivo(Boolean activo) { this.activo = activo; }

    /** @return Lista de zonas */
    public List<ZonaDTO> getZonas() { return zonas; }
    /** @param zonas Lista a establecer */
    public void setZonas(List<ZonaDTO> zonas) { this.zonas = zonas; }
}
