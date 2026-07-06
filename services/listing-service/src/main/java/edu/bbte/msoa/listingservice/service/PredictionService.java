package edu.bbte.msoa.listingservice.service;

import edu.bbte.msoa.listingservice.dto.PredictionRequest;
import edu.bbte.msoa.listingservice.dto.PredictionResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;

@Service
public class PredictionService {

    private final RestTemplate restTemplate;
    private final String predictionServiceUrl;

    public PredictionService(
            @Value("${PREDICTION_SERVICE_URL:http://prediction-service:8083/predict}") String predictionServiceUrl) {
        this.restTemplate = new RestTemplate();
        this.predictionServiceUrl = predictionServiceUrl;
    }

    public BigDecimal getPredictedPrice(PredictionRequest request) {
        try {
            PredictionResponse response = restTemplate.postForObject(
                    predictionServiceUrl,
                    request,
                    PredictionResponse.class
            );

            if (response != null && response.predictedPrice() != null) {
                return response.predictedPrice();
            }
            throw new RuntimeException("Empty response from prediction service");
        } catch (Exception e) {
            throw new RuntimeException("Error accessing prediction service " + e.getMessage(), e);
        }
    }
}
