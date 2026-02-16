package com.jmrs.gestionparkings.dto;

import lombok.Data;
import java.util.List;

@Data
public class ParkingDTO {
    private Long idParking;
    private String nombre;
    private List<ZonaDTO> zonas;
}

@Data
class ZonaDTO {
    private Long idZona;
    private String nombre;
    private List<EstacionDTO> estaciones;
}

@Data
class EstacionDTO {
    private Long idEstacion;
    private String codigoEstacion;
    private String estadoActual; // L, O, M
}
