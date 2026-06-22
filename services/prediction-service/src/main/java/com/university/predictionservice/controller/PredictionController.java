package com.university.predictionservice.controller;

import com.university.predictionservice.dto.PredictionRequest;
import com.university.predictionservice.dto.PredictionResponse;
import com.university.predictionservice.service.PredictionService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/predictions")
public class PredictionController {

    private final PredictionService predictionService;

    public PredictionController(PredictionService predictionService) {
        this.predictionService = predictionService;
    }

    @PostMapping("/price")
    public PredictionResponse predictPrice(@Valid @RequestBody PredictionRequest request) {
        return predictionService.predictPrice(request);
    }
}
