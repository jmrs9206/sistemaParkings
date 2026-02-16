package com.jmrs.gestionparkings.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.ZonedDateTime;

@Entity
@Table(name = "ESTACIONES")
@Getter
@Setter
public class Estacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idEstacion;

    @Column(name = "codigo_estacion", nullable = false, unique = true)
    private String codigoEstacion;

    @Column(name = "id_sensor", nullable = false, unique = true)
    private String idSensor;

    @Column(name = "estado_actual", length = 1)
    private String estadoActual; // 'L', 'O', 'M'

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_zona", nullable = false)
    private Zona zona;

    @Column(name = "created_at", insertable = false, updatable = false)
    private ZonedDateTime createdAt;
}
