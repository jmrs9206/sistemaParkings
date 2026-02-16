package com.jmrs.gestionparkings.repository;

import com.jmrs.gestionparkings.model.Parking;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ParkingRepository extends JpaRepository<Parking, Integer> {
    List<Parking> findByActivoTrue();
}
