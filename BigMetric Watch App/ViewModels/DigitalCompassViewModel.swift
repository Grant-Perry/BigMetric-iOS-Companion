//
//  DigitalCompassViewModel.swift
//  BigMetric Watch App
//

import Foundation
import CoreLocation
import Observation

/// A view model that provides heading, cardinal direction, and coordinate updates for the DigitalCompassView.
@Observable
final class DigitalCompassViewModel: NSObject, CLLocationManagerDelegate {

   // MARK: - Public Outputs

   private(set) var headingDegrees: Double = 0.0
   private(set) var cardinalDirection: String = "N"
   private(set) var coordinate: CLLocationCoordinate2D?
   private(set) var locationName: String = "Unknown"

   // MARK: - Private

   private let locationManager = CLLocationManager()

   // MARK: - Init

   override init() {
	  super.init()
	  locationManager.delegate = self
	  locationManager.desiredAccuracy = kCLLocationAccuracyBest
	  locationManager.headingFilter = kCLHeadingFilterNone
	  locationManager.requestWhenInUseAuthorization()
   }

   func start() {
	  if CLLocationManager.headingAvailable() {
		 locationManager.startUpdatingHeading()
	  }
	  locationManager.startUpdatingLocation()
   }

   func stop() {
	  locationManager.stopUpdatingHeading()
	  locationManager.stopUpdatingLocation()
   }

   // MARK: - Preview Helpers

   /// Sets heading for preview purposes only
   func setHeading(_ degrees: Double) {
	  headingDegrees = degrees
	  cardinalDirection = CardinalDirection.from(degrees: degrees).rawValue
   }

   // MARK: - CLLocationManagerDelegate

   func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
	  let updatedHeading = (newHeading.trueHeading >= 0)
	  ? newHeading.trueHeading
	  : newHeading.magneticHeading

	  headingDegrees = updatedHeading
	  cardinalDirection = CardinalDirection.from(degrees: updatedHeading).rawValue
   }

   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
	  guard let latest = locations.last else { return }
	  coordinate = latest.coordinate
   }

   func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
	  return true
   }

   // MARK: - Preview Stub

   static var preview: DigitalCompassViewModel {
	  let vm = DigitalCompassViewModel()
	  vm.coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
	  vm.locationName = "San Francisco"
	  return vm
   }
}
