package edu.bbte.msoa.listingservice.repository;

import edu.bbte.msoa.listingservice.model.CarListing;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CarListingRepository extends JpaRepository<CarListing, Long> {

}
