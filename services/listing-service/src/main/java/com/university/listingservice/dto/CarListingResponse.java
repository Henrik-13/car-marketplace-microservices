package com.university.listingservice.dto;

import java.math.BigDecimal;
import java.time.Instant;

public record CarListingResponse(
    Long id,
    String brand,
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
