package com.jmrs.gestionparkings.repository;

import com.jmrs.gestionparkings.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

/**
 * Interfaz de acceso a datos (DAO) para la entidad Usuario.
 * Proporciona métodos CRUD automáticos mediante Spring Data JPA.
 * 
 * @author JMRS
 * @version 14.1
 */
public interface UsuarioRepository extends JpaRepository<Usuario, Integer> {

    /**
     * Busca un usuario por su nombre de usuario (username).
     * 
     * @param username Nombre de usuario a buscar.
     * @return Opcional con el usuario encontrado.
     */
    Optional<Usuario> findByUsername(String username);
}
