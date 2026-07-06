package edu.bbte.msoa.listingservice.repository;

import edu.bbte.msoa.listingservice.model.CarListing;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CarListingRepository extends JpaRepository<CarListing, Long> {

}
