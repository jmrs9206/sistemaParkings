package com.jmrs.gestionparkings.controller;

import com.jmrs.gestionparkings.dto.ApiResponse;
import com.jmrs.gestionparkings.dto.ParkingDTO;
import com.jmrs.gestionparkings.service.ParkingService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

/**
 * Controlador para la visualización pública de estados de parkings.
 * Sigue el patrón MVC para la interacción con el cliente.
 * 
 * @author JMRS
 * @version 14.1
 */
@RestController
@RequestMapping("/api/parkings")
@CrossOrigin(origins = "*")
public class ParkingController {

    private final ParkingService parkingService;

    /**
     * Constructor para inyección del servicio de parkings.
     * 
     * @param parkingService Lógica de parkings.
     */
    public ParkingController(ParkingService parkingService) {
        this.parkingService = parkingService;
    }

    /**
     * Endpoint para obtener el estado actual de los parkings activos.
     * 
     * @return ResponseEntity con la lista de estados.
     */
    @GetMapping("/status")
    public ResponseEntity<ApiResponse<List<ParkingDTO>>> getParkingStatus() {
        List<ParkingDTO> status = parkingService.getActiveParkingsWithDetails();
        return ResponseEntity.ok(ApiResponse.success(status, "Estado de parkings recuperado"));
    }
}
