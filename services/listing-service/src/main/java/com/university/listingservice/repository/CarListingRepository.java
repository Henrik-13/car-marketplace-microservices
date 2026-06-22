package com.university.listingservice.repository;

import com.university.listingservice.entity.CarListing;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CarListingRepository extends JpaRepository<CarListing, Long> {
}
