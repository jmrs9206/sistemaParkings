package com.jmrs.gestionparkings.model;

import jakarta.persistence.*;
import org.hibernate.annotations.Immutable;

/**
 * Entidad que representa la vista de deuda de abonados para Inteligencia de Negocio (BI).
 * Esta entidad es inmutable ya que mapea una vista de base de datos.
 * 
 * @author JMRS
 * @version 14.1
 */
@Entity
@Table(name = "V_BI_DEUDA_ABONADOS")
@Immutable
public class BIDeudaAbonado {

    /**
     * Identificador único del abonado.
     */
    @Id
    @Column(name = "id_abonado")
    private Long idAbonado;

    /**
     * Nombre completo del abonado.
     */
    private String nombre;
    
    /**
     * Número total de facturas pendientes de pago.
     */
    @Column(name = "total_pendientes")
    private Long totalPendientes;
    
    /**
     * Importe total adeudado por el abonado.
     */
    @Column(name = "deuda_total")
    private Double deudaTotal;

    // Getters manuales para mantener la inmutabilidad de la vista
    public Long getIdAbonado() { return idAbonado; }
    public String getNombre() { return nombre; }
    public Long getTotalPendientes() { return totalPendientes; }
    public Double getDeudaTotal() { return deudaTotal; }
}
