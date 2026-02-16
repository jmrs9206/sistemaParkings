package com.jmrs.gestionparkings.controller;

import com.jmrs.gestionparkings.model.Abonado;
import com.jmrs.gestionparkings.service.AbonadoService;
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
    public ResponseEntity<?> register(@RequestBody Abonado abonado) {
        try {
            Abonado saved = abonadoService.registerSubscriber(abonado);
            return ResponseEntity.ok(saved);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping("/{dni}")
    public ResponseEntity<Abonado> getProfile(@PathVariable String dni) {
        return abonadoService.getAbonadoByDni(dni)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
