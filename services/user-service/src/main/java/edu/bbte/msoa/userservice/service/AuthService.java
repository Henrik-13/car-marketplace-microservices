package edu.bbte.msoa.userservice.service;

import edu.bbte.msoa.userservice.dto.AuthRequest;
import edu.bbte.msoa.userservice.dto.AuthResponse;
import edu.bbte.msoa.userservice.dto.RegisterRequest;
import edu.bbte.msoa.userservice.exception.UserAlreadyExistsException;
import edu.bbte.msoa.userservice.model.User;
import edu.bbte.msoa.userservice.repository.UserRepository;
import edu.bbte.msoa.userservice.security.JwtUtil;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public AuthService(AuthenticationManager authenticationManager, CustomUserDetailsService userDetailsService, JwtUtil jwtUtil, UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.authenticationManager = authenticationManager;
        this.jwtUtil = jwtUtil;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public AuthResponse login(AuthRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.username(), request.password())
        );

        var user = userRepository.findByUsername(request.username())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        var userDetails = org.springframework.security.core.userdetails.User.withUsername(request.username())
                .password("")
                .authorities("ROLE_USER")
                .build();

        return new AuthResponse(jwtUtil.generateToken(userDetails, user.getId()));
    }

    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByUsername(request.username()) || userRepository.existsByEmail(request.email())) {
            throw new UserAlreadyExistsException("User already exists");
        }

        User user = new User();
        user.setUsername(request.username());
        user.setEmail(request.email());
        user.setPassword(passwordEncoder.encode(request.password()));
        user = userRepository.save(user);

        var userDetails = org.springframework.security.core.userdetails.User.withUsername(user.getUsername())
                .password(user.getPassword())
                .roles("ROLE_USER")
                .build();

        return new AuthResponse(jwtUtil.generateToken(userDetails, user.getId()));
    }
}
