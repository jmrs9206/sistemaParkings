package com.jmrs.gestionparkings.controller;

import com.jmrs.gestionparkings.model.Parking;
import com.jmrs.gestionparkings.service.ParkingService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/api/parkings")
@RequiredArgsConstructor
@CrossOrigin(origins = "*") // Para desarrollo local
public class ParkingController {

    private final ParkingService parkingService;

    @GetMapping("/status")
    public List<Parking> getParkingStatus() {
        return parkingService.getActiveParkingsWithDetails();
    }
}
