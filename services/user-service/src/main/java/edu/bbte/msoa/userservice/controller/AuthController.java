package edu.bbte.msoa.userservice.controller;

import edu.bbte.msoa.userservice.dto.AuthRequest;
import edu.bbte.msoa.userservice.dto.AuthResponse;
import edu.bbte.msoa.userservice.dto.RegisterRequest;
import edu.bbte.msoa.userservice.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public AuthResponse register(@Valid @RequestBody RegisterRequest request) {
        return authService.register(request);
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody AuthRequest request) {
        return authService.login(request);
    }
}

