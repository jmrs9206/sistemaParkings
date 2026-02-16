package com.jmrs.gestionparkings.repository;

import com.jmrs.gestionparkings.model.Abonado;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface AbonadoRepository extends JpaRepository<Abonado, Long> {
    Optional<Abonado> findByDniCif(String dniCif);
    Optional<Abonado> findByEmail(String email);
}
