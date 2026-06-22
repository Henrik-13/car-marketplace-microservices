package com.university.predictionservice.repository;

import com.university.predictionservice.entity.CarAttributes;
import java.math.BigDecimal;

public interface PredictionRepository {
    BigDecimal estimatePrice(CarAttributes attributes);
}
