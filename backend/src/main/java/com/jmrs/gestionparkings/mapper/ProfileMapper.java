package com.jmrs.gestionparkings.mapper;

import com.jmrs.gestionparkings.dto.*;
import com.jmrs.gestionparkings.model.*;
import java.util.stream.Collectors;

public class ProfileMapper {

    public static AbonadoDTO toDTO(Abonado abonado) {
        if (abonado == null) return null;
        AbonadoDTO dto = new AbonadoDTO();
        dto.setIdAbonado(abonado.getIdAbonado());
        dto.setNombre(abonado.getNombre());
        dto.setDniCif(abonado.getDniCif());
        dto.setEmail(abonado.getEmail());
        dto.setIban(abonado.getIban());
        return dto;
    }

    public static Abonado toEntity(AbonadoDTO dto) {
        if (dto == null) return null;
        Abonado entity = new Abonado();
        entity.setIdAbonado(dto.getIdAbonado());
        entity.setNombre(dto.getNombre());
        entity.setDniCif(dto.getDniCif());
        entity.setEmail(dto.getEmail());
        entity.setIban(dto.getIban());
        return entity;
    }

    public static ParkingDTO toDTO(Parking parking) {
        if (parking == null) return null;
        ParkingDTO dto = new ParkingDTO();
        dto.setIdParking(parking.getIdParking());
        dto.setNombre(parking.getNombre());
        if (parking.getZonas() != null) {
            dto.setZonas(parking.getZonas().stream()
                .map(ProfileMapper::zonaToDTO)
                .collect(Collectors.toList()));
        }
        return dto;
    }

    private static ZonaDTO zonaToDTO(Zona zona) {
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
        EstacionDTO dto = new EstacionDTO();
        dto.setIdEstacion(estacion.getIdEstacion());
        dto.setCodigoEstacion(estacion.getCodigoEstacion());
        dto.setEstadoActual(estacion.getEstadoActual());
        return dto;
    }
}
