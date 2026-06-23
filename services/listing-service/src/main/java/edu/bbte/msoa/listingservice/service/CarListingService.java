package edu.bbte.msoa.listingservice.service;

import edu.bbte.msoa.listingservice.dto.CarListingRequest;
import edu.bbte.msoa.listingservice.dto.CarListingResponse;
import edu.bbte.msoa.listingservice.model.CarListing;
import edu.bbte.msoa.listingservice.repository.CarListingRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CarListingService {
    private final CarListingRepository repository;

    public CarListingService(CarListingRepository repository) {
        this.repository = repository;
    }

    public List<CarListingResponse> findAll() {
        return repository.findAll().stream().map(this::toResponse).toList();
    }

    public CarListingResponse findById(Long id) {
        return toResponse(repository.findById(id).orElseThrow(() -> new IllegalArgumentException("Listing not found")));
    }

    public CarListingResponse create(CarListingRequest request) {
        CarListing listing = toEntity(new CarListing(), request);
        return toResponse(repository.save(listing));
    }

    public CarListingResponse update(Long id, CarListingRequest request) {
        CarListing listing = repository.findById(id).orElseThrow(() -> new IllegalArgumentException("Listing not found"));
        return toResponse(repository.save(toEntity(listing, request)));
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    private CarListing toEntity(CarListing listing, CarListingRequest request) {
        listing.setMake(request.make());
        listing.setModel(request.model());
        listing.setYear(request.year());
        listing.setMileage(request.mileage());
        listing.setFuelType(request.fuelType());
        listing.setTransmission(request.transmission());
        listing.setDescription(request.description());
        listing.setPrice(request.price());
        return listing;
    }

    private CarListingResponse toResponse(CarListing listing) {
        return new CarListingResponse(
                listing.getId(),
                listing.getUserId(),
                listing.getMake(),
                listing.getModel(),
                listing.getYear(),
                listing.getMileage(),
                listing.getFuelType(),
                listing.getTransmission(),
                listing.getDescription(),
                listing.getPrice(),
                listing.getCreatedAt()
        );
    }
}
