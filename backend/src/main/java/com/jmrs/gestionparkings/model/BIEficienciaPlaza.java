package com.jmrs.gestionparkings.model;

import jakarta.persistence.*;
import org.hibernate.annotations.Immutable;

/**
 * Entidad que representa la vista de eficiencia por plaza/estación para Inteligencia de Negocio (BI).
 * Permite visualizar el rendimiento económico de cada estación.
 * 
 * @author JMRS
 * @version 14.1
 */
@Entity
@Table(name = "V_BI_EFICIENCIA_PLAZAS")
@Immutable
public class BIEficienciaPlaza {

    /**
     * Código identificativo de la estación.
     */
    @Id
    @Column(name = "codigo_estacion")
    private String codigoEstacion;

    /**
     * Número total de estancias registradas en esta estación.
     */
    @Column(name = "total_estancias")
    private Long totalEstancias;
    
    /**
     * Suma total de ingresos generados por la estación.
     */
    @Column(name = "ingresos_generados")
    private Double ingresosGenerados;

    // Getters manuales
    public String getCodigoEstacion() { return codigoEstacion; }
    public Long getTotalEstancias() { return totalEstancias; }
    public Double getIngresosGenerados() { return ingresosGenerados; }
}
