package edu.bbte.msoa.listingservice.dto;

public record PredictionRequest(
        String marca,
        String model,
        Integer an,
        Integer km,
        Integer putere,
        Integer capacitate_cilindrica,
        String cutie_de_viteze,
        String combustibil,
        String transmisie,
        String caroserie,
        String culoare,
        String addons
) {
}
