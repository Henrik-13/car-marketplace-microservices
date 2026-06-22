package com.university.predictionservice.entity;

public record CarAttributes(
    String brand,
    String model,
    Integer year,
    Integer mileage,
    String fuelType,
    String transmission
) {
}
