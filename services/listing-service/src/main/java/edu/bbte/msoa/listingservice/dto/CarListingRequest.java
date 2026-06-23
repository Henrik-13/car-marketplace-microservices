package edu.bbte.msoa.listingservice.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public record CarListingRequest(
        @NotBlank String make,
        @NotBlank String model,
        @NotNull @Min(1900) Integer year,
        @NotNull @Min(0) Integer mileage,
        @NotBlank String fuelType,
        @NotBlank String transmission,
        @NotBlank String description,
        @NotNull @DecimalMin("0.0") BigDecimal price
) {
}
