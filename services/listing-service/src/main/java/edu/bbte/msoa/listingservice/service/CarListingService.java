package edu.bbte.msoa.listingservice.service;

import edu.bbte.msoa.listingservice.dto.CarListingRequest;
import edu.bbte.msoa.listingservice.dto.CarListingResponse;
import edu.bbte.msoa.listingservice.dto.ImageDto;
import edu.bbte.msoa.listingservice.model.CarImage;
import edu.bbte.msoa.listingservice.model.CarListing;
import edu.bbte.msoa.listingservice.repository.CarListingRepository;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

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

    @Cacheable(value = "cars_v2", key = "#id")
    public CarListingResponse findById(Long id) {
        return toResponse(repository.findById(id).orElseThrow(() -> new IllegalArgumentException("Listing not found")));
    }

    public CarListingResponse create(CarListingRequest request) {
        CarListing listing = toEntity(new CarListing(), request);
        listing.setUserId(currentUserId());
        return toResponse(repository.save(listing));
    }

    @CacheEvict(value = "cars_v2", key = "#id")
    public CarListingResponse update(Long id, CarListingRequest request) {
        CarListing listing = repository.findById(id).orElseThrow(() -> new IllegalArgumentException("Listing not found"));
        return toResponse(repository.save(toEntity(listing, request)));
    }

    @CacheEvict(value = "cars_v2", key = "#id")
    public void delete(Long id) {
        repository.deleteById(id);
    }

    @Transactional
    @CacheEvict(value = "cars_v2", key = "#id")
    public CarListingResponse addImageToListing(Long id, String imageUrl, boolean isPrimary) {
        CarListing listing = repository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Listing not found"));

        CarImage newImage = new CarImage();
        newImage.setImageUrl(imageUrl);
        newImage.setIsPrimary(isPrimary);

        if (isPrimary) {
            listing.getImages().forEach(img -> img.setIsPrimary(false));
        }

        listing.addImage(newImage);
        return toResponse(repository.save(listing));
    }

    @Transactional
    @CacheEvict(value = "cars_v2", key = "#id")
    public CarListingResponse removeImageFromListing(Long id, Long imageId) {
        CarListing listing = repository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Listing not found"));

        // Find the image to remove by its ID
        CarImage imageToRemove = listing.getImages().stream()
                .filter(img -> img.getId().equals(imageId))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Image not found for this listing"));

        listing.getImages().remove(imageToRemove);

        // If the removed image was primary and there are still images left, set the first one as primary
        if (imageToRemove.getIsPrimary() && !listing.getImages().isEmpty()) {
            listing.getImages().get(0).setIsPrimary(true);
        }

        return toResponse(repository.save(listing));
    }

    public String getImageUrl(Long id, Long imageId) {
        CarListing listing = repository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Listing not found"));

        return listing.getImages().stream()
                .filter(img -> img.getId().equals(imageId))
                .map(CarImage::getImageUrl)
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Image not found for this listing"));
    }

    private CarListing toEntity(CarListing listing, CarListingRequest request) {
        listing.setMake(request.make());
        listing.setModel(request.model());
        listing.setYear(request.year());
        listing.setMileage(request.mileage());
        listing.setFuelType(request.fuelType());
        listing.setTransmission(request.transmission());
        listing.setPower(request.power());
        listing.setEngineCapacity(request.engineCapacity());
        listing.setDrivetrain(request.drivetrain());
        listing.setBodyType(request.bodyType());
        listing.setColor(request.color());
        listing.setAddons(request.addons());
        listing.setDescription(request.description());
        listing.setPrice(request.price());
        return listing;
    }

    private CarListingResponse toResponse(CarListing listing) {

        String primaryUrl = listing.getImages().stream()
                .filter(CarImage::getIsPrimary)
                .map(CarImage::getImageUrl)
                .findFirst()
                .orElse(null);

        List<ImageDto> imageDtos = listing.getImages().stream()
                .map(img -> new ImageDto(img.getId(), img.getImageUrl(), img.getIsPrimary()))
                .toList();

        return new CarListingResponse(
                listing.getId(),
                listing.getUserId(),
                listing.getMake(),
                listing.getModel(),
                listing.getYear(),
                listing.getMileage(),
                listing.getFuelType(),
                listing.getTransmission(),
                listing.getPower(),
                listing.getEngineCapacity(),
                listing.getDrivetrain(),
                listing.getBodyType(),
                listing.getColor(),
                listing.getAddons(),
                listing.getDescription(),
                listing.getPrice(),
                primaryUrl,
                imageDtos,
                listing.getCreatedAt()
        );
    }

    private Long currentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || authentication.getPrincipal() == null) {
            throw new IllegalStateException("Authenticated user id is required");
        }

        Object principal = authentication.getPrincipal();
        if (principal instanceof Long userId) {
            return userId;
        }
        if (principal instanceof Number number) {
            return number.longValue();
        }
        if (principal instanceof String value && !value.isBlank()) {
            return Long.valueOf(value);
        }

        throw new IllegalStateException("Authenticated user id is required");
    }
}
