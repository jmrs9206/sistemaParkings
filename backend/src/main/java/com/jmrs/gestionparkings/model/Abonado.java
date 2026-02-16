package com.jmrs.gestionparkings.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.ZonedDateTime;
import java.util.List;

@Entity
@Table(name = "ABONADOS")
@Getter
@Setter
public class Abonado {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idAbonado;

    @Column(name = "nombre_razon_social", nullable = false)
    private String nombreRazonSocial;

    @Column(name = "dni_cif", nullable = false, unique = true)
    private String dniCif;

    @Column(nullable = false, unique = true)
    private String email;

    private String telefono;

    @Column(name = "id_localidad", nullable = false)
    private Integer idLocalidad;

    private Boolean activo = true;

    @Column(name = "created_at", insertable = false, updatable = false)
    private ZonedDateTime createdAt;

    @OneToMany(mappedBy = "abonado")
    private List<DatosPagoAbonado> metodosPago;
}
