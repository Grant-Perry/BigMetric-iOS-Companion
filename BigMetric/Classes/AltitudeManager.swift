import SwiftUI
import CoreMotion
import CoreLocation
import Combine

@Observable
class AltitudeManager: NSObject, CLLocationManagerDelegate, ObservableObject {
   private let altimeter = CMAltimeter()
   private let locationManager = CLLocationManager()
   private var cancellable: AnyCancellable?

   // Formatter for altitude string
   private let numberFormatter: NumberFormatter = {
	  let formatter = NumberFormatter()
	  formatter.numberStyle = .decimal
	  formatter.maximumFractionDigits = 0
	  return formatter
   }()

   var altitudeString: String = ""
   var currentAltitude: Double = 0.0
   var baseAltitude: Double = 0.0
   var relativeAltitude: Double = 0.0

   override init() {
	  super.init()
	  locationManager.delegate = self
	  locationManager.desiredAccuracy = kCLLocationAccuracyBest
   }

   private func formatAltitude(_ altitude: Double) -> String {
	  guard let formattedString = numberFormatter.string(from: NSNumber(value: altitude)) else {
		 return "0"
	  }
	  return "\(formattedString)'"
   }

   func startUpdates() {
	  guard CMAltimeter.isRelativeAltitudeAvailable() else {
		 print("Barometer not available on this device.")
		 return
	  }

	  locationManager.requestWhenInUseAuthorization()
	  locationManager.startUpdatingLocation()

	  altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { [weak self] data, error in
		 guard let self = self else { return }

		 if let data = data {
			let relativeChange = data.relativeAltitude.doubleValue * 3.28084 // Convert to feet
			self.relativeAltitude = relativeChange
			self.currentAltitude = self.baseAltitude + relativeChange
			self.altitudeString = self.formatAltitude(self.currentAltitude)
		 } else if let error = error {
			print("Error reading altitude: \(error)")
		 }
	  }
   }

   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
	  guard let location = locations.last else { return }
	  let altitude = location.altitude * 3.28084 // Convert meters to feet

	  if baseAltitude == 0.0 {
		 baseAltitude = altitude
		 currentAltitude = altitude
		 altitudeString = formatAltitude(currentAltitude)
	  }
   }

   func stopUpdates() {
	  locationManager.stopUpdatingLocation()
	  altimeter.stopRelativeAltitudeUpdates()
	  cancellable?.cancel()
   }
}
