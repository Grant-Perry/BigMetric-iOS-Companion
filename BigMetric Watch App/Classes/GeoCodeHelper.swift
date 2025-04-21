//  GeoCode.swift
//
//  Created by: Grant Perry on 4/18/23.
//    Modified: Monday March 11, 2024 at 9:13:17 AM

import SwiftUI
import Observation
import CoreLocation
import OSLog

@Observable
class GeoCodeHelper: NSObject {
   private let logger = Logger(subsystem: "com.gp.BigMetric.GeoCodeHelper", category: "geocode")

   // MARK: - Logging Utility
   /// Persists the message to the log and prints it for debugging.
   private func logAndPersist(_ message: String) {
	  logger.info("\(message, privacy: .public)")
	  let timestamp = ISO8601DateFormatter().string(from: Date())
	  let entry = "[\(timestamp)] \(message)"
	  var logs = UserDefaults.standard.stringArray(forKey: "logHistory") ?? []
	  logs.append(entry)
	  UserDefaults.standard.set(Array(logs.suffix(250)), forKey: "logHistory") // limit to last 250 logs
#if DEBUG
	  print(message)
#endif
   }

   /// ``getAddressFromCoordinates(_:longitude:completion:)``
   /// Asynchronously retrieves the full address corresponding to the specified latitude and longitude, using reverse geocoding.
   /// - Parameters:
   ///   - latitude: The latitude of the location as `CLLocationDegrees`.
   ///   - longitude: The longitude of the location as `CLLocationDegrees`.
   ///   - completion: A closure that takes an optional `CLPlacemark` and returns `Void`. This closure is called with the address as a `CLPlacemark` if
   ///   reverse geocoding is successful, or `nil` if it fails.
   ///
   /// This function initializes a `CLLocation` with the provided coordinates and uses `CLGeocoder` to perform reverse geocoding. On success,
   ///  it formats and returns the full address. On failure, it logs an error message and returns `nil`.
   func getAddressFromCoordinates(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees,
								  completion: @escaping (CLPlacemark?) -> Void) {
	  let location = CLLocation(latitude: latitude, longitude: longitude)
	  let geocoder = CLGeocoder()

	  geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
		 if let error = error {
			self.logAndPersist("Reverse geocoding failed with error: \(error.localizedDescription)")
			completion(nil)
			return
		 }

		 if let placemark = placemarks?.first {
			let address = "\(placemark.subThoroughfare ?? ""), \(placemark.thoroughfare ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.postalCode ?? ""), \(placemark.country ?? "")"
			self.logAndPersist("Address: \(address) - lat: \(latitude) - long: \(longitude) - [getAddressFromCoordinates]")
			completion(placemark)
		 } else {
			self.logAndPersist("No address found for the given coordinates")
			completion(nil)
		 }
	  }
   }

   /// ``getCityNameFromCoordinates(_:longitude:completion:)``
   /// Asynchronously retrieves the city name for the given latitude and longitude using reverse geocoding.
   /// - Parameters:
   ///   - latitude: The latitude of the location as `CLLocationDegrees`.
   ///   - longitude: The longitude of the location as `CLLocationDegrees`.
   ///   - completion: A closure that takes an optional `CLPlacemark` (the city name) and returns `Void`. The closure is executed with the city name
   ///   if the operation is successful, or `nil` if it fails.
   ///
   /// This function creates a `CLLocation` object with the specified coordinates and uses `CLGeocoder` to perform reverse geocoding to extract
   /// the city name from the location data. It handles success and failure cases by logging the outcome and executing the completion handler with the result.
   func getCityNameFromCoordinates(_ latitude: CLLocationDegrees,
								   _ longitude: CLLocationDegrees,
								   completion: @escaping (CLPlacemark?) -> Void) {
	  let location = CLLocation(latitude: latitude, longitude: longitude)
	  let geocoder = CLGeocoder()

	  geocoder.reverseGeocodeLocation(location) { [self] (placemarks, error) in
		 if let error = error {
			self.logAndPersist("Reverse geocoding failed with error: \(error.localizedDescription)")
			completion(nil)
			return
		 }

		 if let pm = placemarks {
			self.printPlaceMarks(PM: pm)
		 }

		 if let placemark = placemarks?.first {
			self.logAndPersist("placemark: \(placemark)\n-----------")
			completion(placemark)
		 } else {
			self.logAndPersist("No city found for the given coordinates - lat: \(latitude) - long: \(longitude) - [getCityNameFromCoordinates]")
			completion(nil)
		 }
	  }
   }

   // debug function to print the placemarks received from a reverse GEOCode lookup address
   func printPlaceMarks(PM: [CLPlacemark]) {
	  self.logAndPersist("PRINTING PLACEMARKS: __________")
	  for placemark in PM {
		 let properties: [(String, String?)] = [
			("Name", placemark.name),
			("Thoroughfare", placemark.thoroughfare),
			("SubThoroughfare", placemark.subThoroughfare),
			("Locality", placemark.locality),
			("SubLocality", placemark.subLocality),
			("Administrative Area", placemark.administrativeArea),
			("SubAdministrative Area", placemark.subAdministrativeArea),
			("Postal Code", placemark.postalCode),
			("Country", placemark.country),
			("ISO Country Code", placemark.isoCountryCode),
		 ]
		 for (label, value) in properties {
			if let value {
			   self.logAndPersist("\(label): \(value)")
			}
		 }
		 self.logAndPersist("-------------------")
	  }
   }
}
