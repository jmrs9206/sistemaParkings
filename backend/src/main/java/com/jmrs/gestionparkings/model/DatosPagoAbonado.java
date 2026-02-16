package com.jmrs.gestionparkings.model;

import jakarta.persistence.*;
import java.time.ZonedDateTime;

/**
 * Entidad que almacena la información de los métodos de pago asociados a un abonado.
 * Implementa el almacenamiento seguro mediante tokens de pasarela.
 * 
 * @author JMRS
 * @version 14.1
 */
@Entity
@Table(name = "DATOS_PAGO_ABONADO")
public class DatosPagoAbonado {

    /**
     * Identificador único del registro de pago.
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idDatoPago;

    /**
     * Abonado al que pertenece este método de pago.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_abonado", nullable = false)
    private Abonado abonado;

    /**
     * Identificador del método de pago (Tarjeta, PayPal, etc.).
     */
    @Column(name = "id_metodo_pago", nullable = false)
    private Integer idMetodoPago;

    /**
     * Token generado por la pasarela de pago para cobros recurrentes.
     */
    @Column(name = "token_pasarela", nullable = false)
    private String tokenPasarela;

    /**
     * Indica si este es el método de pago preferido para el abonado.
     */
    @Column(name = "es_metodo_por_defecto")
    private Boolean esMetodoPorDefecto = false;

    /**
     * Indica si el método de pago está activo.
     */
    private Boolean activo = true;

    /**
     * Fecha de creación del registro.
     */
    @Column(name = "created_at", insertable = false, updatable = false)
    private ZonedDateTime createdAt;

    // Getters y Setters manuales
    public Long getIdDatoPago() { return idDatoPago; }
    public void setIdDatoPago(Long idDatoPago) { this.idDatoPago = idDatoPago; }
    public Abonado getAbonado() { return abonado; }
    public void setAbonado(Abonado abonado) { this.abonado = abonado; }
    public Integer getIdMetodoPago() { return idMetodoPago; }
    public void setIdMetodoPago(Integer idMetodoPago) { this.idMetodoPago = idMetodoPago; }
    public String getTokenPasarela() { return tokenPasarela; }
    public void setTokenPasarela(String tokenPasarela) { this.tokenPasarela = tokenPasarela; }
    public Boolean getEsMetodoPorDefecto() { return esMetodoPorDefecto; }
    public void setEsMetodoPorDefecto(Boolean esMetodoPorDefecto) { this.esMetodoPorDefecto = esMetodoPorDefecto; }
    public Boolean getActivo() { return activo; }
    public void setActivo(Boolean activo) { this.activo = activo; }
    public ZonedDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(ZonedDateTime createdAt) { this.createdAt = createdAt; }
}
