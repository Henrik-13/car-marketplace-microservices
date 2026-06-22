package com.university.predictionservice.service;

import com.university.predictionservice.dto.PredictionRequest;
import com.university.predictionservice.dto.PredictionResponse;
import java.math.BigDecimal;
import org.springframework.stereotype.Service;

@Service
public class PredictionService {

    public PredictionResponse predictPrice(PredictionRequest request) {
        BigDecimal basePrice = BigDecimal.valueOf(30000);
        int age = Math.max(0, java.time.Year.now().getValue() - request.year());

        BigDecimal agePenalty = BigDecimal.valueOf(age).multiply(BigDecimal.valueOf(1200));
        BigDecimal mileagePenalty = BigDecimal.valueOf(request.mileage()).multiply(BigDecimal.valueOf(0.03));

        BigDecimal estimatedPrice = basePrice.subtract(agePenalty).subtract(mileagePenalty);
        if (estimatedPrice.compareTo(BigDecimal.valueOf(1000)) < 0) {
            estimatedPrice = BigDecimal.valueOf(1000);
        }

        return new PredictionResponse(estimatedPrice.setScale(2, java.math.RoundingMode.HALF_UP));
    }
}
