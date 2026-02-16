package com.jmrs.gestionparkings.service;

import com.jmrs.gestionparkings.dto.AbonadoDTO;
import com.jmrs.gestionparkings.mapper.ProfileMapper;
import com.jmrs.gestionparkings.model.Abonado;
import com.jmrs.gestionparkings.repository.AbonadoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AbonadoService {

    private final AbonadoRepository repository;

    public AbonadoDTO registerSubscriber(AbonadoDTO dto) {
        // Validación básica: Ver si ya existe por DNI o Email
        if (repository.findByDniCif(dto.getDniCif()).isPresent()) {
            throw new RuntimeException("El DNI/CIF ya está registrado en el sistema.");
        }
        if (repository.findByEmail(dto.getEmail()).isPresent()) {
            throw new RuntimeException("El Email ya está registrado.");
        }
    }

    @Transactional(readOnly = true)
    public Optional<Abonado> getAbonadoByDni(String dni) {
        return abonadoRepository.findByDniCif(dni);
    }
}
