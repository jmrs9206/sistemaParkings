package com.jmrs.gestionparkings.mapper;

import com.jmrs.gestionparkings.dto.*;
import com.jmrs.gestionparkings.model.*;
import java.util.stream.Collectors;

public class ProfileMapper {

    public static AbonadoDTO toDTO(Abonado abonado) {
        if (abonado == null) return null;
        AbonadoDTO dto = new AbonadoDTO();
        dto.setIdAbonado(abonado.getIdAbonado());
        dto.setNombre(abonado.getNombreRazonSocial());
        dto.setDniCif(abonado.getDniCif());
        dto.setEmail(abonado.getEmail());
        // IBAN usually comes from DatosPago if needed, for simplification keep what was there
        // If entity has no iban, we just leave it or handle it. 
        // Based on previous code it seemed it expected iban.
        return dto;
    }

    public static Abonado toEntity(AbonadoDTO dto) {
        if (dto == null) return null;
        Abonado entity = new Abonado();
        entity.setIdAbonado(dto.getIdAbonado());
        entity.setNombreRazonSocial(dto.getNombre());
        entity.setDniCif(dto.getDniCif());
        entity.setEmail(dto.getEmail());
        return entity;
    }

    public static ParkingDTO toDTO(Parking parking) {
        if (parking == null) return null;
        ParkingDTO dto = new ParkingDTO();
        dto.setIdParking(parking.getIdParking().intValue()); 
        // Handle potential type mismatch if parking ID remained Long
        dto.setNombre(parking.getNombre());
        if (parking.getZonas() != null) {
            dto.setZonas(parking.getZonas().stream()
                .map(ProfileMapper::zonaToDTO)
                .collect(Collectors.toList()));
        }
        return dto;
    }

    private static ZonaDTO zonaToDTO(Zona zona) {
        if (zona == null) return null;
        ZonaDTO dto = new ZonaDTO();
        dto.setIdZona(zona.getIdZona());
        dto.setNombre(zona.getNombre());
        if (zona.getEstaciones() != null) {
            dto.setEstaciones(zona.getEstaciones().stream()
                .map(ProfileMapper::estacionToDTO)
                .collect(Collectors.toList()));
        }
        return dto;
    }

    private static EstacionDTO estacionToDTO(Estacion estacion) {
        if (estacion == null) return null;
        EstacionDTO dto = new EstacionDTO();
        dto.setIdEstacion(estacion.getIdEstacion());
        dto.setCodigoEstacion(estacion.getCodigoEstacion());
        dto.setEstadoActual(estacion.getEstadoActual());
        return dto;
    }
}
