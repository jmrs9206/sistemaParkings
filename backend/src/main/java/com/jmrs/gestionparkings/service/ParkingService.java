package com.jmrs.gestionparkings.service;

import com.jmrs.gestionparkings.model.Parking;
import com.jmrs.gestionparkings.repository.ParkingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ParkingService {

    private final ParkingRepository parkingRepository;

    @Transactional(readOnly = true)
    public List<Parking> getActiveParkingsWithDetails() {
        return parkingRepository.findByActivoTrue();
    }
}
