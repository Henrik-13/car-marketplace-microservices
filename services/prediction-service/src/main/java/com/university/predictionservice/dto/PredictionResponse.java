package com.university.predictionservice.dto;

import java.math.BigDecimal;

public record PredictionResponse(BigDecimal estimatedPrice) {
}
