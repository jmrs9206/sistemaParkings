package com.jmrs.gestionparkings.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class AbonadoDTO {
    private Integer idAbonado;

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

    // Getters and Setters
    public Integer getIdAbonado() { return idAbonado; }
    public void setIdAbonado(Integer idAbonado) { this.idAbonado = idAbonado; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getDniCif() { return dniCif; }
    public void setDniCif(String dniCif) { this.dniCif = dniCif; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getIban() { return iban; }
    public void setIban(String iban) { this.iban = iban; }
}
