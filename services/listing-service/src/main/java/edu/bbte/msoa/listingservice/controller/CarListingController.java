package edu.bbte.msoa.listingservice.controller;

import edu.bbte.msoa.listingservice.dto.CarListingRequest;
import edu.bbte.msoa.listingservice.dto.CarListingResponse;
import edu.bbte.msoa.listingservice.service.CarListingService;
import edu.bbte.msoa.listingservice.service.ImageStorageService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/cars")
public class CarListingController {

    private final CarListingService service;
    private final ImageStorageService imageStorageService;

    public CarListingController(CarListingService service, ImageStorageService imageStorageService) {
        this.service = service;
        this.imageStorageService = imageStorageService;
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
                    response = service.addImageToListing(id, imageUrl, isPrimary);
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
        String imageUrl = service.getImageUrl(id, imageId);

        // 2. Delete the image from the storage service
        imageStorageService.deleteImage(imageUrl);

        // 3. Remove the image from the listing in the listing service
        return service.removeImageFromListing(id, imageId);
    }
}
