package com.jmrs.gestionparkings.controller;

import com.jmrs.gestionparkings.dto.ApiResponse;
import com.jmrs.gestionparkings.dto.ParkingDTO;
import com.jmrs.gestionparkings.service.ParkingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/api/parkings")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ParkingController {

    private final ParkingService parkingService;

    @GetMapping("/status")
    public ResponseEntity<ApiResponse<List<ParkingDTO>>> getParkingStatus() {
        List<ParkingDTO> status = parkingService.getActiveParkingsWithDetails();
        return ResponseEntity.ok(ApiResponse.success(status, "Estado de parkings recuperado"));
    }
}
