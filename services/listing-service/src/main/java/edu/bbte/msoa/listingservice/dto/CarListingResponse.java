package edu.bbte.msoa.listingservice.dto;

import java.math.BigDecimal;
import java.time.Instant;

public record CarListingResponse(
        Long id,
        Long userId,
        String make,
        String model,
        Integer year,
        Integer mileage,
        String fuelType,
        String transmission,
        String description,
        BigDecimal price,
        Instant createdAt
) {
}
