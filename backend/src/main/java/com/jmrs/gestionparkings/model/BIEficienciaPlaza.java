package com.jmrs.gestionparkings.model;

import jakarta.persistence.*;
import lombok.Getter;
import org.hibernate.annotations.Immutable;

@Entity
@Table(name = "V_BI_EFICIENCIA_PLAZAS")
@Immutable
@Getter
public class BIEficienciaPlaza {

    @Id
    @Column(name = "codigo_estacion")
    private String codigoEstacion;

    @Column(name = "total_estancias")
    private Long totalEstancias;
    
    @Column(name = "ingresos_generados")
    private Double ingresosGenerados;
}
