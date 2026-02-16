package com.jmrs.gestionparkings.repository;

import com.jmrs.gestionparkings.model.BIEficienciaPlaza;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BIEficienciaRepository extends JpaRepository<BIEficienciaPlaza, String> {
}
