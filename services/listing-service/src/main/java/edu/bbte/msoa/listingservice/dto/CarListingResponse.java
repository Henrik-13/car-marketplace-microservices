package edu.bbte.msoa.listingservice.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

public record CarListingResponse(
        Long id,
        Long userId,
        String make,
        String model,
        Integer year,
        Integer mileage,
        String fuelType,
        String transmission,
        Integer power,
        Integer engineCapacity,
        String drivetrain,
        String bodyType,
        String color,
        String addons,
        String description,
        BigDecimal price,
        String primaryImageUrl,
        List<ImageDto> images,
        Instant createdAt
) {
}
