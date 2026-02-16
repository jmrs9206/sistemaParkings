package com.jmrs.gestionparkings.controller;

import com.jmrs.gestionparkings.dto.ApiResponse;
import com.jmrs.gestionparkings.model.BIDeudaAbonado;
import com.jmrs.gestionparkings.model.BIEficienciaPlaza;
import com.jmrs.gestionparkings.service.BIService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

/**
 * Controlador para la exportación de datos de Inteligencia de Negocio (BI).
 * Proporciona endpoints para el análisis de deuda y eficiencia de estaciones.
 * 
 * @author JMRS
 * @version 14.1
 */
@RestController
@RequestMapping("/api/bi")
@CrossOrigin(origins = "*")
public class BIController {

    private final BIService biService;

    /**
     * Constructor único para la inyección de dependencias.
     * 
     * @param biService Servicio de lógica de BI.
     */
    public BIController(BIService biService) {
        this.biService = biService;
    }

    /**
     * Obtiene el listado de abonados con facturas pendientes.
     * 
     * @return ResponseEntity con la lista de deudas detectadas.
     */
    @GetMapping("/debts")
    public ResponseEntity<ApiResponse<List<BIDeudaAbonado>>> getSubscriberDebts() {
        List<BIDeudaAbonado> debts = biService.getSubscriberDebts();
        return ResponseEntity.ok(ApiResponse.success(debts, "Análisis de deuda recuperado"));
    }

    /**
     * Obtiene el rendimiento económico por estación.
     * 
     * @return ResponseEntity con la lista de eficiencia por estación.
     */
    @GetMapping("/efficiency")
    public ResponseEntity<ApiResponse<List<BIEficienciaPlaza>>> getSpotEfficiency() {
        List<BIEficienciaPlaza> efficiency = biService.getSpotEfficiency();
        return ResponseEntity.ok(ApiResponse.success(efficiency, "Análisis de eficiencia recuperado"));
    }
}
