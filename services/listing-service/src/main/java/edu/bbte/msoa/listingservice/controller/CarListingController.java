package edu.bbte.msoa.listingservice.controller;

import edu.bbte.msoa.listingservice.dto.CarListingRequest;
import edu.bbte.msoa.listingservice.dto.CarListingResponse;
import edu.bbte.msoa.listingservice.service.CarListingService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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
