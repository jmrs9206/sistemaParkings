package com.jmrs.gestionparkings.controller;

import com.jmrs.gestionparkings.dto.AbonadoDTO;
import com.jmrs.gestionparkings.dto.ApiResponse;
import com.jmrs.gestionparkings.service.AbonadoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/abonados")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AbonadoController {

    private final AbonadoService abonadoService;

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AbonadoDTO>> register(@Valid @RequestBody AbonadoDTO dto) {
        AbonadoDTO saved = abonadoService.registerSubscriber(dto);
        return ResponseEntity.ok(ApiResponse.success(saved, "Abonado registrado con éxito"));
    }

    @GetMapping("/{dni}")
    public ResponseEntity<ApiResponse<AbonadoDTO>> getProfile(@PathVariable String dni) {
        return abonadoService.getAbonadoByDni(dni)
                .map(com.jmrs.gestionparkings.mapper.ProfileMapper::toDTO)
                .map(dto -> ResponseEntity.ok(ApiResponse.success(dto, "Perfil recuperado")))
                .orElse(ResponseEntity.status(404).body(ApiResponse.error("Abonado no encontrado")));
    }
}
