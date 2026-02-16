package com.jmrs.gestionparkings.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.ZonedDateTime;

@Entity
@Table(name = "DATOS_PAGO_ABONADO")
@Getter
@Setter
public class DatosPagoAbonado {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idDatoPago;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_abonado", nullable = false)
    private Abonado abonado;

    @Column(name = "id_metodo_pago", nullable = false)
    private Integer idMetodoPago;

    @Column(name = "token_pasarela", nullable = false)
    private String tokenPasarela;

    @Column(name = "es_metodo_por_defecto")
    private Boolean esMetodoPorDefecto = false;

    private Boolean activo = true;

    @Column(name = "created_at", insertable = false, updatable = false)
    private ZonedDateTime createdAt;
}
