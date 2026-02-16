package com.jmrs.gestionparkings.service;

import com.jmrs.gestionparkings.dto.ParkingDTO;
import com.jmrs.gestionparkings.mapper.ProfileMapper;
import com.jmrs.gestionparkings.repository.ParkingRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Servicio encargado de la gestión de parkings y la consulta de sus estados.
 * Esta clase forma parte de la capa de Modelo (Lógica de Negocio) del sistema MVC.
 * 
 * @author JMRS
 * @version 14.1
 */
@Service
public class ParkingService {

    private final ParkingRepository repository;

    /**
     * Constructor para la inyección de dependencias del repositorio de datos.
     * 
     * @param repository Repositorio de acceso a datos de parkings (DAO).
     */
    public ParkingService(ParkingRepository repository) {
        this.repository = repository;
    }

    /**
     * Recupera y mapea a DTO los parkings que se encuentran activos en el sistema.
     * 
     * @return Lista de objetos ParkingDTO con el estado actual.
     */
    public List<ParkingDTO> getActiveParkingsWithDetails() {
        return repository.findAll().stream()
                .filter(p -> p.getActivo() != null && p.getActivo())
                .map(ProfileMapper::toDTO)
                .collect(Collectors.toList());
    }
}
