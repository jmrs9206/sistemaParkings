package com.jmrs.gestionparkings.service;

import com.jmrs.gestionparkings.dto.ParkingDTO;
import com.jmrs.gestionparkings.mapper.ProfileMapper;
import com.jmrs.gestionparkings.repository.ParkingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ParkingService {

    private final ParkingRepository repository;

    public List<ParkingDTO> getActiveParkingsWithDetails() {
        return repository.findAll().stream()
                .filter(p -> Boolean.TRUE.equals(p.getActivo()))
                .map(ProfileMapper::toDTO)
                .collect(Collectors.toList());
    }
}
