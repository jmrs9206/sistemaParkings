package com.jmrs.gestionparkings.service;

import com.jmrs.gestionparkings.model.BIDeudaAbonado;
import com.jmrs.gestionparkings.model.BIEficienciaPlaza;
import com.jmrs.gestionparkings.repository.BIDeudaRepository;
import com.jmrs.gestionparkings.repository.BIEficienciaRepository;
import org.springframework.stereotype.Service;
import java.util.List;

/**
 * Servicio encargado de recopilar datos agregados para la capa de Inteligencia de Negocio.
 * Procesa la información proveniente de las vistas de base de datos.
 * 
 * @author JMRS
 * @version 14.1
 */
@Service
public class BIService {

    private final BIDeudaRepository deudaRepository;
    private final BIEficienciaRepository eficienciaRepository;

    /**
     * Constructor para inyección de repositorios DAO.
     * 
     * @param deudaRepository Repositorio de deudas.
     * @param eficienciaRepository Repositorio de eficiencia.
     */
    public BIService(BIDeudaRepository deudaRepository, BIEficienciaRepository eficienciaRepository) {
        this.deudaRepository = deudaRepository;
        this.eficienciaRepository = eficienciaRepository;
    }

    /**
     * Consulta el estado de deudas de todos los abonados registrados.
     * 
     * @return Lista de deudas por abonado.
     */
    public List<BIDeudaAbonado> getSubscriberDebts() {
        return deudaRepository.findAll();
    }

    /**
     * Consulta el rendimiento de todas las estaciones registradas.
     * 
     * @return Lista de eficiencia por estación.
     */
    public List<BIEficienciaPlaza> getSpotEfficiency() {
        return eficienciaRepository.findAll();
    }
}
