package com.jmrs.gestionparkings.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDate;
import java.time.ZonedDateTime;
import java.util.List;

@Entity
@Table(name = "PARKINGS")
@Getter
@Setter
public class Parking {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idParking;

    @Column(nullable = false, unique = true)
    private String nombre;

    @Column(name = "id_localidad", nullable = false)
    private Integer idLocalidad;

    private Boolean activo = true;

    @Column(name = "fecha_baja")
    private LocalDate fechaBaja;

    @Column(name = "created_at", insertable = false, updatable = false)
    private ZonedDateTime createdAt;

    @OneToMany(mappedBy = "parking", cascade = CascadeType.ALL)
    private List<Zona> zonas;
}
