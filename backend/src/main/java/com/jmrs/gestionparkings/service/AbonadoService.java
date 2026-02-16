package com.jmrs.gestionparkings.service;

import com.jmrs.gestionparkings.dto.AbonadoDTO;
import com.jmrs.gestionparkings.mapper.ProfileMapper;
import com.jmrs.gestionparkings.model.Abonado;
import com.jmrs.gestionparkings.repository.AbonadoRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

/**
 * Servicio de lógica de negocio (Controlador Lógico) para la gestión de Abonados.
 * Gestiona las reglas de validación y persistencia de clientes abonados.
 * 
 * @author JMRS
 * @version 14.1
 */
@Service
public class AbonadoService {

    private final AbonadoRepository repository;

    /**
     * Constructor para inyectar la capa de datos (Repository/DAO).
     * 
     * @param repository Repositorio de acceso a datos de abonados.
     */
    public AbonadoService(AbonadoRepository repository) {
        this.repository = repository;
    }

    /**
     * Procesa el registro de un nuevo abonado validando duplicados.
     * 
     * @param dto Objeto de transferencia de datos con la información del abonado.
     * @return DTO del abonado persistido.
     * @throws RuntimeException Si el DNI o Email ya existen.
     */
    public AbonadoDTO registerSubscriber(AbonadoDTO dto) {
        // Validación básica: Ver si ya existe por DNI o Email
        if (repository.findByDniCif(dto.getDniCif()).isPresent()) {
            throw new RuntimeException("El DNI/CIF ya está registrado en el sistema.");
        }
        if (repository.findByEmail(dto.getEmail()).isPresent()) {
            throw new RuntimeException("El Email ya está registrado.");
        }

        Abonado abonado = ProfileMapper.toEntity(dto);
        Abonado saved = repository.save(abonado);
        
        // Generar el código de abonado profesional (ej. PHX-05-260216-0001)
        // [FRANQUICIA]-[ID_PARKING_2D]-[YYMMDD]-[ID_ABONADO_4D]
        String datePart = java.time.format.DateTimeFormatter.ofPattern("yyMMdd").format(java.time.LocalDate.now());
        String parkingPart = String.format("%02d", (saved.getIdParking() != null ? saved.getIdParking() : 0));
        String code = "PHX-" + parkingPart + "-" + datePart + "-" + String.format("%04d", saved.getIdAbonado());
        
        saved.setCodigoAbonado(code);
        saved = repository.save(saved); 

        return ProfileMapper.toDTO(saved);
    }

    /**
     * Busca un abonado por su DNI/CIF.
     * 
     * @param dni Documento de identidad.
     * @return Un opcional con la entidad Abonado si se encuentra.
     */
    @Transactional(readOnly = true)
    public Optional<Abonado> getAbonadoByDni(String dni) {
        return repository.findByDniCif(dni);
    }
}
