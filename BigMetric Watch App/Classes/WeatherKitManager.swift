//
//  WeatherKitManager.swift
//  BigMetric Watch App (WorkingVersion, replaced with BrokenVersion approach)
//
//  Now uses the same logic from BrokenVersion:
//  - On location-based updates, we do .getWeather(for:), which fetches city name, then calls fetchWeather(for:).
//  - We store results in tempVar, symbolVar, etc., the same as BrokenVersion.
//  - We also call unifyWorkoutManager.updateWeatherInfo(from:) from debugScreen if needed.
//
import SwiftUI
import Observation
@preconcurrency import WeatherKit
import CoreLocation

@Observable
class WeatherKitManager: NSObject, CLLocationManagerDelegate, ObservableObject {

   // MARK: - If you store reference to your unified manager for lastLocation
   var unifiedWorkoutManager: UnifiedWorkoutManager?

   // Add debug property
   private let debugTag = "[WeatherKit] "

   // MARK: - Apple WeatherKit objects
   let sharedService = WeatherService.shared
   let weatherService = WeatherService()

   // MARK: - Variables for weather data
   var isErrorAlert: Bool = false
   var latitude: Double = 0
   var longitude: Double = 0

   var precipForecast: Double = 0
   var precipForecast2: Double = 0
   var precipForecastAmount: Double = 0
   var windSpeedVar: Double = 0

   var dailyForecast: Forecast<DayWeather>?
   var hourlyForecast: Forecast<HourWeather>?
   var weekForecast: [Forecasts] = []

   var highTempVar: String = ""
   var locationName: String = ""
   var lowTempVar: String = ""
   var symbolHourly: String = ""
   var symbolVar: String = "xmark"
   var tempHour: String = ""
   var tempVar: String = ""
   var windDirectionVar: String = ""

   var date: Date = .now

   // This property tracks if we've already fetched weather for the current workout
   private var hasWeatherForWorkout = false

   /// Initialize
   init(unifiedWorkoutManager: UnifiedWorkoutManager? = nil) {
	  self.unifiedWorkoutManager = unifiedWorkoutManager
	  super.init()
	  print("[WeatherKit] Initializing with manager: \(unifiedWorkoutManager != nil)")
   }

   // MARK: - Reset weather state for new workout
   func resetWeatherState() {
	  hasWeatherForWorkout = false
	  locationName = ""
	  precipForecast = 0
	  precipForecast2 = 0
	  precipForecastAmount = 0
	  weekForecast.removeAll()
	  highTempVar = ""
	  lowTempVar = ""
	  symbolHourly = ""
	  symbolVar = "xmark"
	  tempHour = ""
	  tempVar = ""
	  windSpeedVar = 0
	  windDirectionVar = ""
   }

   // If you need to start location updates purely from WeatherKitManager:
   // you can do that here, but typically we rely on the same location from unifiedWorkoutManager.
   func startWeatherTracking() {
	  guard let manager = unifiedWorkoutManager else { return }
	  hasWeatherForWorkout = false
	  manager.LMDelegate.delegate = self
   }

   func stopWeatherTracking() {
	  guard let manager = unifiedWorkoutManager else { return }
	  manager.LMDelegate.delegate = nil
	  locationName = ""
	  hasWeatherForWorkout = false
   }

   // MARK: - CLLocationManagerDelegate
   public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
	  guard !hasWeatherForWorkout,
			let location = locations.last,
			location.horizontalAccuracy <= 50.0
	  else { return }

	  print("[WeatherKit] Got accurate location => fetching weather once per workout.")
	  Task {
		 await getWeather(for: location.coordinate)
		 hasWeatherForWorkout = true
	  }
   }

   public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
	  print("[WeatherKit] Location error: \(error.localizedDescription)")
   }

   // MARK: - Weather fetching with location name (BrokenVersion approach)
   @MainActor
   func getWeather(for coordinate: CLLocationCoordinate2D) async {
	  print("[WeatherKit] getWeather called with coordinate: \(coordinate)")
	  guard !hasWeatherForWorkout else {
		 print("[WeatherKit] Already fetched weather for this workout.")
		 return
	  }

	  do {
		 // 1) Reverse geocode => city name
		 let geocoder = CLGeocoder()
		 let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
		 if let placemark = try await geocoder.reverseGeocodeLocation(location).first {
			self.locationName = placemark.locality ?? "Weather"
			print("[WeatherKit] locationName set to: \(self.locationName)")
		 } else {
			self.locationName = "Unknown"
			print("[WeatherKit] Geocode => No placemark found.")
		 }

		 // 2) actual WeatherKit data
		 let weather = try await weatherService.weather(for: location)
		 print("[WeatherKit] WeatherKit fetch success => building forecast data.")
		 let current = weather.currentWeather
		 let hourly = weather.hourlyForecast.first
		 let dailyFx = try? await weatherService.weather(for: location, including: .daily)

		 if let dailyForecast = dailyFx, !dailyForecast.isEmpty {
			self.dailyForecast = dailyForecast
			self.highTempVar = String(format: "%.0f", dailyForecast.first?.highTemperature.converted(to: .fahrenheit).value ?? 0)
			self.lowTempVar  = String(format: "%.0f", dailyForecast.first?.lowTemperature.converted(to: .fahrenheit).value ?? 0)

			let howManyDays = min(dailyForecast.count, 10)
			weekForecast = (0..<howManyDays).map { idx in
			   let dw = dailyForecast[idx]
			   let symbolName = dw.symbolName
			   let minTemp = String(format: "%.0f", dw.lowTemperature.converted(to: .fahrenheit).value)
			   let maxTemp = String(format: "%.0f", dw.highTemperature.converted(to: .fahrenheit).value)
			   return Forecasts(symbolName: symbolName, minTemp: minTemp, maxTemp: maxTemp)
			}
		 } else {
			print("[WeatherKit] dailyForecast => none found.")
		 }

		 if let hr = hourly {
			self.precipForecast2 = hr.precipitationChance
			self.precipForecast = hr.precipitationAmount.value
			self.symbolHourly = hr.symbolName
			self.tempHour = String(format: "%.0f", hr.temperature.converted(to: .fahrenheit).value)
		 }

		 self.tempVar = String(format: "%.0f", current.temperature.converted(to: .fahrenheit).value)
		 self.symbolVar = current.symbolName
		 self.windSpeedVar = current.wind.speed.converted(to: .milesPerHour).value
		 self.windDirectionVar = CardinalDirection(course: current.wind.direction.converted(to: .degrees).value).rawValue

		 hasWeatherForWorkout = true
	  } catch {
		 print("[WeatherKit] getWeather => error: \(error.localizedDescription)")
		 if let e = error as? URLError, e.code == .notConnectedToInternet {
			print("[WeatherKit] Network offline => isErrorAlert=true")
			isErrorAlert = true
		 }
	  }
   }

   // If you want a dailyForecast/hours approach, replicate as needed:
   @discardableResult
   func dailyForecast(for coordinate: CLLocationCoordinate2D) async -> Forecast<DayWeather>? {
	  do {
		 let loc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
		 let forecast = try await weatherService.weather(for: loc, including: .daily)
		 return forecast
	  } catch {
		 print("[WeatherKit] dailyForecast => error: \(error.localizedDescription)")
		 return nil
	  }
   }

   @discardableResult
   func hourlyForecast(for coordinate: CLLocationCoordinate2D) async -> Forecast<HourWeather>? {
	  do {
		 let loc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
		 let forecast = try await weatherService.weather(for: loc, including: .hourly)
		 return forecast
	  } catch {
		 print("[WeatherKit] hourlyForecast => error: \(error.localizedDescription)")
		 return nil
	  }
   }

   struct Forecasts: Identifiable {
	  let id = UUID()
	  let symbolName: String
	  let minTemp: String
	  let maxTemp: String
   }
}
