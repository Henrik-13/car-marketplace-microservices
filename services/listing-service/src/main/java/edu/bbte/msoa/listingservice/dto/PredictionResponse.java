package edu.bbte.msoa.listingservice.dto;

import java.math.BigDecimal;

public record PredictionResponse(
        BigDecimal predictedPrice
) {
}
