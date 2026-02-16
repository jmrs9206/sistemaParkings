package com.jmrs.gestionparkings.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class AbonadoDTO {
    private Long idAbonado;

    @NotBlank(message = "El nombre es obligatorio")
    @Size(min = 3, max = 100)
    private String nombre;

    @NotBlank(message = "El DNI/CIF es obligatorio")
    private String dniCif;

    @Email(message = "Formato de email inválido")
    @NotBlank(message = "el email es obligatorio")
    private String email;

    @NotBlank(message = "El IBAN es obligatorio")
    private String iban;
}
