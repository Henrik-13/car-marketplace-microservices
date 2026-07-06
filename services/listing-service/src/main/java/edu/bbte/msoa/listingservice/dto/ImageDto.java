package edu.bbte.msoa.listingservice.dto;

public record ImageDto(
        Long id,
        String url,
        Boolean isPrimary
) {
}
