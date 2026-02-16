package com.jmrs.gestionparkings.controller;

import com.jmrs.gestionparkings.dto.AbonadoDTO;
import com.jmrs.gestionparkings.dto.ApiResponse;
import com.jmrs.gestionparkings.service.AbonadoService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controlador de interfaz para la gestión de abonados.
 * Proporciona servicios de registro y consulta de perfiles.
 * Sigue el patrón MVC como controlador de entrada.
 * 
 * @author JMRS
 * @version 14.1
 */
@RestController
@RequestMapping("/api/abonados")
@CrossOrigin(origins = "*")
public class AbonadoController {

    private final AbonadoService abonadoService;

    /**
     * Constructor para la inyección de dependencias del servicio de abonados.
     * 
     * @param abonadoService Lógica de negocio de abonados.
     */
    public AbonadoController(AbonadoService abonadoService) {
        this.abonadoService = abonadoService;
    }

    /**
     * Registra un nuevo abonado en el sistema.
     * 
     * @param dto Datos del abonado a registrar.
     * @return Respuesta con el abonado guardado y mensaje de éxito.
     */
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AbonadoDTO>> register(@Valid @RequestBody AbonadoDTO dto) {
        AbonadoDTO saved = abonadoService.registerSubscriber(dto);
        return ResponseEntity.ok(ApiResponse.success(saved, "Abonado registrado con éxito"));
    }

    /**
     * Recupera el perfil de un abonado mediante su DNI/CIF.
     * 
     * @param dni Identificador legal del abonado.
     * @return ResponseEntity con el perfil si existe, o error 404.
     */
    @GetMapping("/{dni}")
    public ResponseEntity<ApiResponse<AbonadoDTO>> getProfile(@PathVariable String dni) {
        return abonadoService.getAbonadoByDni(dni)
                .map(com.jmrs.gestionparkings.mapper.ProfileMapper::toDTO)
                .map(dto -> ResponseEntity.ok(ApiResponse.success(dto, "Perfil recuperado")))
                .orElse(ResponseEntity.status(404).body(ApiResponse.error("Abonado no encontrado")));
    }
}
