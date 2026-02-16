package com.jmrs.gestionparkings.dto;

import java.time.LocalDateTime;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class AbonadoDTO {
    private Integer idAbonado;
    private String nombreRazonSocial;
    private String dniCif;
    private String email;
    private String telefono;
    private Integer idLocalidad;
    private Integer idParking;
    private String matriculaPrincipal;
    private String matriculaSecundaria1;
    private String matriculaSecundaria2;
    private String codigoAbonado;
    private Boolean activo;
    private LocalDateTime createdAt;

    // Getters y Setters

    /** @return ID Abonado */
    public Integer getIdAbonado() { return idAbonado; }
    /** @param idAbonado ID a establecer */
    public void setIdAbonado(Integer idAbonado) { this.idAbonado = idAbonado; }

    /** @return Nombre/Razón Social */
    public String getNombreRazonSocial() { return nombreRazonSocial; }
    /** @param nombreRazonSocial Nombre a establecer */
    public void setNombreRazonSocial(String nombreRazonSocial) { this.nombreRazonSocial = nombreRazonSocial; }

    /** @return DNI/CIF */
    public String getDniCif() { return dniCif; }
    /** @param dniCif DNI a establecer */
    public void setDniCif(String dniCif) { this.dniCif = dniCif; }

    /** @return Email */
    public String getEmail() { return email; }
    /** @param email Email a establecer */
    public void setEmail(String email) { this.email = email; }

    /** @return Teléfono */
    public String getTelefono() { return telefono; }
    /** @param telefono Teléfono a establecer */
    public void setTelefono(String telefono) { this.telefono = telefono; }

    /** @return ID Localidad */
    public Integer getIdLocalidad() { return idLocalidad; }
    /** @param idLocalidad ID a establecer */
    public void setIdLocalidad(Integer idLocalidad) { this.idLocalidad = idLocalidad; }

    /** @return Matrícula principal */
    public String getMatriculaPrincipal() { return matriculaPrincipal; }
    /** @param matriculaPrincipal Matrícula a establecer */
    public void setMatriculaPrincipal(String matriculaPrincipal) { this.matriculaPrincipal = matriculaPrincipal; }

    /** @return Matrícula secundaria 1 */
    public String getMatriculaSecundaria1() { return matriculaSecundaria1; }
    /** @param matriculaSecundaria1 Matrícula a establecer */
    public void setMatriculaSecundaria1(String matriculaSecundaria1) { this.matriculaSecundaria1 = matriculaSecundaria1; }

    /** @return Matrícula secundaria 2 */
    public String getMatriculaSecundaria2() { return matriculaSecundaria2; }
    /** @param matriculaSecundaria2 Matrícula a establecer */
    public void setMatriculaSecundaria2(String matriculaSecundaria2) { this.matriculaSecundaria2 = matriculaSecundaria2; }

    /** @return Estado activo */
    public Boolean getActivo() { return activo; }
    /** @param activo Estado a establecer */
    public void setActivo(Boolean activo) { this.activo = activo; }

    /** @return Fecha de creación */
    public LocalDateTime getCreatedAt() { return createdAt; }
    /** @param createdAt Fecha a establecer */
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    /** @return ID Parking */
    public Integer getIdParking() { return idParking; }
    /** @param idParking ID a establecer */
    public void setIdParking(Integer idParking) { this.idParking = idParking; }
}
