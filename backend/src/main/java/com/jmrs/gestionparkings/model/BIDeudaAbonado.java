package com.jmrs.gestionparkings.model;

import jakarta.persistence.*;
import lombok.Getter;
import org.hibernate.annotations.Immutable;

@Entity
@Table(name = "V_BI_DEUDA_ABONADOS")
@Immutable
@Getter
public class BIDeudaAbonado {

    @Id
    @Column(name = "id_abonado")
    private Long idAbonado;

    private String nombre;
    
    @Column(name = "total_pendientes")
    private Long totalPendientes;
    
    @Column(name = "deuda_total")
    private Double deudaTotal;
}
