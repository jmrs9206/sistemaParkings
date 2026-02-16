package com.jmrs.gestionparkings.repository;

import com.jmrs.gestionparkings.model.BIDeudaAbonado;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BIDeudaRepository extends JpaRepository<BIDeudaAbonado, Long> {
}
