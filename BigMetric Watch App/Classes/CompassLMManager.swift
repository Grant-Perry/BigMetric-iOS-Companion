import CoreLocation
import SwiftUI

class CompassLMManager: NSObject, ObservableObject, CLLocationManagerDelegate {
   private let locationManager = CLLocationManager()
   @Published var heading: String = "SE"
   @Published var course: Double = 90.0
   @Published var compassError: Error? = nil
   @Published var isCalibrating: Bool = false
   @Published var isCompassAvailable: Bool = true

   override init() {
	  super.init()
	  setupLocationManager()
   }

   private func setupLocationManager() {
	  locationManager.delegate = self
	  locationManager.desiredAccuracy = kCLLocationAccuracyBest
	  locationManager.headingFilter = 5
	  locationManager.headingOrientation = .portrait
   }

   func startUpdates() {
	  guard CLLocationManager.headingAvailable() else {
		 isCompassAvailable = false
		 return
	  }

	  locationManager.startUpdatingLocation()
	  locationManager.startUpdatingHeading()
   }

   func stopUpdates() {
	  locationManager.stopUpdatingHeading()
	  locationManager.stopUpdatingLocation()
   }

   // MARK: - CLLocationManagerDelegate
   func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
	  // Only update if accuracy is acceptable
	  guard newHeading.headingAccuracy >= 0 else {
		 isCalibrating = true
		 return
	  }

	  isCalibrating = false
	  compassError = nil
	  course = newHeading.trueHeading

	  // FIX: Use the defined static method on CardinalDirection
	  heading = CardinalDirection.from(degrees: newHeading.trueHeading).rawValue
   }

   func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
	  compassError = error
	  if let error = error as? CLError {
		 switch error.code {
			case .denied:
			   isCompassAvailable = false
			case .headingFailure:
			   isCalibrating = true
			default:
			   break
		 }
	  }
   }
}
