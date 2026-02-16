package com.jmrs.gestionparkings.controller;

import com.jmrs.gestionparkings.model.BIDeudaAbonado;
import com.jmrs.gestionparkings.model.BIEficienciaPlaza;
import com.jmrs.gestionparkings.service.BIService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/api/bi")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class BIController {

    private final BIService biService;

    @GetMapping("/debts")
    public List<BIDeudaAbonado> getSubscriberDebts() {
        return biService.getSubscriberDebts();
    }

    @GetMapping("/efficiency")
    public List<BIEficienciaPlaza> getSpotEfficiency() {
        return biService.getSpotEfficiency();
    }
}
