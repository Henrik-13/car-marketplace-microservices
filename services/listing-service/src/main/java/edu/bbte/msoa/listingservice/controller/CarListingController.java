package edu.bbte.msoa.listingservice.controller;

import edu.bbte.msoa.listingservice.dto.CarListingRequest;
import edu.bbte.msoa.listingservice.dto.CarListingResponse;
import edu.bbte.msoa.listingservice.dto.PredictionRequest;
import edu.bbte.msoa.listingservice.service.CarListingService;
import edu.bbte.msoa.listingservice.service.ImageStorageService;
import edu.bbte.msoa.listingservice.service.PredictionService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/cars")
public class CarListingController {

    private final CarListingService carListingService;
    private final ImageStorageService imageStorageService;
    private final PredictionService predictionService;

    public CarListingController(CarListingService carListingService, ImageStorageService imageStorageService, PredictionService predictionService) {
        this.carListingService = carListingService;
        this.imageStorageService = imageStorageService;
        this.predictionService = predictionService;
    }

    @GetMapping
    public List<CarListingResponse> findAll() {
        return carListingService.findAll();
    }

    @GetMapping("/{id}")
    public CarListingResponse findById(@PathVariable Long id) {
        return carListingService.findById(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public CarListingResponse create(@Valid @RequestBody CarListingRequest request) {
        return carListingService.create(request);
    }

    @PutMapping("/{id}")
    public CarListingResponse update(@PathVariable Long id, @Valid @RequestBody CarListingRequest request) {
        return carListingService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        carListingService.delete(id);
    }

    @PostMapping("/{id}/images")
    public CarListingResponse uploadImages(
            @PathVariable Long id,
            @RequestParam("files") List<MultipartFile> files,
            @RequestParam(value = "primaryIndex", defaultValue = "0") int primaryIndex) {

        CarListingResponse response = null;

        try {
            for (int i = 0; i < files.size(); i++) {
                MultipartFile file = files.get(i);
                if (!file.isEmpty()) {
                    String imageUrl = imageStorageService.uploadImage(file);

                    boolean isPrimary = (i == primaryIndex);
                    response = carListingService.addImageToListing(id, imageUrl, isPrimary);
                }
            }
        } catch (IOException e) {
            throw new RuntimeException("Error uploading images", e);
        }

        return response;
    }

    @DeleteMapping("/{id}/images/{imageId}")
    public CarListingResponse deleteImage(@PathVariable Long id, @PathVariable Long imageId) {
        // 1. Get the image URL from the listing service
        String imageUrl = carListingService.getImageUrl(id, imageId);

        // 2. Delete the image from the storage service
        imageStorageService.deleteImage(imageUrl);

        // 3. Remove the image from the listing in the listing service
        return carListingService.removeImageFromListing(id, imageId);
    }

    @PostMapping("/predict-price")
    public Map<String, BigDecimal> predictPrice(@Valid @RequestBody PredictionRequest request) {
        BigDecimal predictedPrice = predictionService.getPredictedPrice(request);
        return Map.of("suggestedPrice", predictedPrice);
    }
}
