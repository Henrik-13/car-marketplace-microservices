package com.university.predictionservice.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record PredictionRequest(
    @NotBlank String brand,
    @NotBlank String model,
    @NotNull @Min(1900) Integer year,
    @NotNull @Min(0) Integer mileage,
    @NotBlank String fuelType,
    @NotBlank String transmission
) {
}
