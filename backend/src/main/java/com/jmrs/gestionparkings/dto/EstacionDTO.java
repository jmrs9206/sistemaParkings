package com.jmrs.gestionparkings.dto;

public class EstacionDTO {
    private Integer idEstacion;
    private String codigoEstacion;
    private String estadoActual;

    // Getters and Setters
    public Integer getIdEstacion() { return idEstacion; }
    public void setIdEstacion(Integer idEstacion) { this.idEstacion = idEstacion; }
    public String getCodigoEstacion() { return codigoEstacion; }
    public void setCodigoEstacion(String codigoEstacion) { this.codigoEstacion = codigoEstacion; }
    public String getEstadoActual() { return estadoActual; }
    public void setEstadoActual(String estadoActual) { this.estadoActual = estadoActual; }
}
