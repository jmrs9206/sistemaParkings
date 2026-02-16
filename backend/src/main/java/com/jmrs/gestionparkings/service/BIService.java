package com.jmrs.gestionparkings.service;

import com.jmrs.gestionparkings.model.BIDeudaAbonado;
import com.jmrs.gestionparkings.model.BIEficienciaPlaza;
import com.jmrs.gestionparkings.repository.BIDeudaRepository;
import com.jmrs.gestionparkings.repository.BIEficienciaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class BIService {

    private final BIDeudaRepository deudaRepository;
    private final BIEficienciaRepository eficienciaRepository;

    public List<BIDeudaAbonado> getSubscriberDebts() {
        return deudaRepository.findAll();
    }

    public List<BIEficienciaPlaza> getSpotEfficiency() {
        return eficienciaRepository.findAll();
    }
}
