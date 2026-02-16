package com.jmrs.gestionparkings.service;

import com.jmrs.gestionparkings.model.Abonado;
import com.jmrs.gestionparkings.repository.AbonadoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AbonadoService {

    private final AbonadoRepository abonadoRepository;

    @Transactional
    public Abonado registerSubscriber(Abonado abonado) {
        // Validación básica: Ver si ya existe por DNI o Email
        if (abonadoRepository.findByDniCif(abonado.getDniCif()).isPresent()) {
            throw new RuntimeException("El DNI/CIF ya está registrado en el sistema.");
        }
        if (abonadoRepository.findByEmail(abonado.getEmail()).isPresent()) {
            throw new RuntimeException("El Email ya está registrado.");
        }
        return abonadoRepository.save(abonado);
    }

    @Transactional(readOnly = true)
    public Optional<Abonado> getAbonadoByDni(String dni) {
        return abonadoRepository.findByDniCif(dni);
    }
}
