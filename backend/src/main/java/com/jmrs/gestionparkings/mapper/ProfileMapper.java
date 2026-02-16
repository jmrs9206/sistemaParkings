package com.jmrs.gestionparkings.mapper;

import com.jmrs.gestionparkings.dto.*;
import com.jmrs.gestionparkings.model.*;
import java.util.stream.Collectors;

/**
 * Clase de utilidad para el mapeo entre Entidades (Model) y Objetos de Transferencia de Datos (DTO).
 * Permite mantener la separación de capas en el patrón MVC.
 * 
 * @author JMRS
 * @version 14.1
 */
public class ProfileMapper {

    /**
     * Convierte una entidad Abonado a su representación DTO.
     * 
     * @param entity Objeto de base de datos.
     * @return DTO para la capa de interfaz.
     */
    public static AbonadoDTO toDTO(Abonado entity) {
        if (entity == null) return null;
        AbonadoDTO dto = new AbonadoDTO();
        dto.setIdAbonado(entity.getIdAbonado());
        dto.setNombreRazonSocial(entity.getNombreRazonSocial());
        dto.setDniCif(entity.getDniCif());
        dto.setEmail(entity.getEmail());
        dto.setTelefono(entity.getTelefono());
        dto.setIdLocalidad(entity.getIdLocalidad());
        dto.setIdParking(entity.getIdParking());
        dto.setMatriculaPrincipal(entity.getMatriculaPrincipal());
        dto.setMatriculaSecundaria1(entity.getMatriculaSecundaria1());
        dto.setMatriculaSecundaria2(entity.getMatriculaSecundaria2());
        dto.setCodigoAbonado(entity.getCodigoAbonado());
        dto.setActivo(entity.getActivo());
        dto.setCreatedAt(entity.getCreatedAt());
        return dto;
    }

    /**
     * Convierte un DTO de Abonado a su entidad persistente.
     * 
     * @param dto Objeto proveniente de la interfaz.
     * @return Entidad para persistencia en base de datos.
     */
    public static Abonado toEntity(AbonadoDTO dto) {
        if (dto == null) return null;
        Abonado entity = new Abonado();
        entity.setIdAbonado(dto.getIdAbonado());
        entity.setNombreRazonSocial(dto.getNombreRazonSocial());
        entity.setDniCif(dto.getDniCif());
        entity.setEmail(dto.getEmail());
        entity.setTelefono(dto.getTelefono());
        entity.setIdLocalidad(dto.getIdLocalidad());
        entity.setIdParking(dto.getIdParking());
        entity.setMatriculaPrincipal(dto.getMatriculaPrincipal());
        entity.setMatriculaSecundaria1(dto.getMatriculaSecundaria1());
        entity.setMatriculaSecundaria2(dto.getMatriculaSecundaria2());
        entity.setCodigoAbonado(dto.getCodigoAbonado());
        entity.setActivo(dto.getActivo() != null ? dto.getActivo() : true);
        return entity;
    }

    /**
     * Convierte una entidad Parking a ParkingDTO.
     * 
     * @param entity Entidad parking.
     * @return DTO parking.
     */
    public static ParkingDTO toDTO(Parking entity) {
        if (entity == null) return null;
        ParkingDTO dto = new ParkingDTO();
        dto.setIdParking(entity.getIdParking()); 
        dto.setNombre(entity.getNombre());
        dto.setIdLocalidad(entity.getIdLocalidad());
        dto.setActivo(entity.getActivo());
        if (entity.getZonas() != null) {
            dto.setZonas(entity.getZonas().stream()
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
