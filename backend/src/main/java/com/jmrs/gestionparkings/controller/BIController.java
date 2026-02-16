package com.jmrs.gestionparkings.controller;

import com.jmrs.gestionparkings.dto.ApiResponse;
import com.jmrs.gestionparkings.model.BIDeudaAbonado;
import com.jmrs.gestionparkings.model.BIEficienciaPlaza;
import com.jmrs.gestionparkings.service.BIService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
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
    public ResponseEntity<ApiResponse<List<BIDeudaAbonado>>> getSubscriberDebts() {
        List<BIDeudaAbonado> debts = biService.getSubscriberDebts();
        return ResponseEntity.ok(ApiResponse.success(debts, "Análisis de deuda recuperado"));
    }

    @GetMapping("/efficiency")
    public ResponseEntity<ApiResponse<List<BIEficienciaPlaza>>> getSpotEfficiency() {
        List<BIEficienciaPlaza> efficiency = biService.getSpotEfficiency();
        return ResponseEntity.ok(ApiResponse.success(efficiency, "Análisis de eficiencia recuperado"));
    }
}
