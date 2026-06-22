package com.university.listingservice.controller;

import com.university.listingservice.dto.CarListingRequest;
import com.university.listingservice.dto.CarListingResponse;
import com.university.listingservice.service.CarListingService;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/cars")
public class CarListingController {

    private final CarListingService service;

    public CarListingController(CarListingService service) {
        this.service = service;
    }

    @GetMapping
    public List<CarListingResponse> findAll() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public CarListingResponse findById(@PathVariable Long id) {
        return service.findById(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public CarListingResponse create(@Valid @RequestBody CarListingRequest request) {
        return service.create(request);
    }

    @PutMapping("/{id}")
    public CarListingResponse update(@PathVariable Long id, @Valid @RequestBody CarListingRequest request) {
        return service.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        service.delete(id);
    }
}
