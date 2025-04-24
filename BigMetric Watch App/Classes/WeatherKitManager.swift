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

   private var independentLocationManager: CLLocationManager?
   private var isIndependentTracking = false

   /// Initialize
   init(unifiedWorkoutManager: UnifiedWorkoutManager? = nil) {
	  self.unifiedWorkoutManager = unifiedWorkoutManager
	  super.init()
	  self.logAndPersist_external("[WeatherKit] Initializing with manager: \(unifiedWorkoutManager != nil)")
   }

   // MARK: - Centralized Log via UnifiedWorkoutManager
   private func logAndPersist_external(_ message: String) {
	  if let unifiedMgr = unifiedWorkoutManager {
		 unifiedMgr.logAndPersist(message)
	  } else {
#if DEBUG
		 print(message)
#endif
	  }
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
	  // Log reset state centrally
	  logAndPersist_external("[WeatherKit] Weather state reset")
   }

   // If you need to start location updates purely from WeatherKitManager:
   // you can do that here, but typically we rely on the same location from unifiedWorkoutManager.
   func startWeatherTracking() {
	  if let manager = unifiedWorkoutManager {
		 hasWeatherForWorkout = false
		 manager.LMDelegate.delegate = self
	  } else {
		 // Setup independent tracking if no workout manager
		 isIndependentTracking = true
		 independentLocationManager = CLLocationManager()
		 independentLocationManager?.delegate = self
		 independentLocationManager?.desiredAccuracy = kCLLocationAccuracyBest
		 independentLocationManager?.startUpdatingLocation()
	  }
   }

   func stopWeatherTracking() {
	  if let manager = unifiedWorkoutManager {
		 manager.LMDelegate.delegate = nil
	  } else {
		 independentLocationManager?.stopUpdatingLocation()
		 independentLocationManager = nil
	  }
	  locationName = ""
	  hasWeatherForWorkout = false
	  isIndependentTracking = false
   }

   // MARK: - CLLocationManagerDelegate
   public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
	  guard let location = locations.last,
			location.horizontalAccuracy <= 50.0
	  else { return }

	  // Allow updates if independent tracking or no weather yet
	  if isIndependentTracking || !hasWeatherForWorkout {
		 logAndPersist_external("[WeatherKit] Got accurate location => fetching weather.")
		 Task {
			await getWeather(for: location.coordinate)
			if !isIndependentTracking {
			   hasWeatherForWorkout = true
			}
		 }
	  }
   }

   public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
	  logAndPersist_external("[WeatherKit] Location error: \(error.localizedDescription)")
   }

   // MARK: - Weather fetching with location name (BrokenVersion approach)
   @MainActor
   func getWeather(for coordinate: CLLocationCoordinate2D) async {
	  logAndPersist_external("[WeatherKit] getWeather called with coordinate: \(coordinate)")
	  do {
		 // 1) Reverse geocode => city name
		 let geocoder = CLGeocoder()
		 let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
		 if let placemark = try await geocoder.reverseGeocodeLocation(location).first {
			self.locationName = placemark.locality ?? "Weather"
			logAndPersist_external("[WeatherKit] locationName set to: \(self.locationName)")
		 } else {
			self.locationName = "Unknown"
			logAndPersist_external("[WeatherKit] Geocode => No placemark found.")
		 }

		 // 2) actual WeatherKit data
		 let weather = try await weatherService.weather(for: location)
		 logAndPersist_external("[WeatherKit] WeatherKit fetch success => building forecast data.")
		 let current = weather.currentWeather
		 let hourlyForecasts = weather.hourlyForecast
		 // Get the next hour that's actually ahead of current time
		 let currentHour = Calendar.current.component(.hour, from: Date())
		 let nextHour = hourlyForecasts.first { forecast in
			let forecastHour = Calendar.current.component(.hour, from: forecast.date)
			return forecastHour > currentHour
		 }
		 // Debug logging
		 if let nextHour {
			let formatter = DateFormatter()
			formatter.timeStyle = .short
			logAndPersist_external("[WeatherKit] Next hour forecast for: \(formatter.string(from: nextHour.date))")
		 }

		 if let nextHour {
			self.symbolHourly = nextHour.symbolName
			self.tempHour = String(format: "%.0f", nextHour.temperature.converted(to: .fahrenheit).value)
		 } else {
			// If we can't find next hour, use first hour of next day
			if let tomorrowFirst = hourlyForecasts.first(where: { Calendar.current.isDateInTomorrow($0.date) }) {
			   self.symbolHourly = tomorrowFirst.symbolName
			   self.tempHour = String(format: "%.0f", tomorrowFirst.temperature.converted(to: .fahrenheit).value)
			}
		 }

		 self.tempVar = String(format: "%.0f", current.temperature.converted(to: .fahrenheit).value)
		 self.symbolVar = current.symbolName
		 self.windSpeedVar = current.wind.speed.converted(to: .milesPerHour).value
		 self.windDirectionVar = CardinalDirection.from(degrees: current.wind.direction.converted(to: .degrees).value).rawValue

		 if let dailyFx = try? await weatherService.weather(for: location, including: .daily), !dailyFx.isEmpty {
			self.dailyForecast = dailyFx
			self.highTempVar = String(format: "%.0f", dailyFx.first?.highTemperature.converted(to: .fahrenheit).value ?? 0)
			self.lowTempVar  = String(format: "%.0f", dailyFx.first?.lowTemperature.converted(to: .fahrenheit).value ?? 0)

			let howManyDays = min(dailyFx.count, 10)
			weekForecast = (0..<howManyDays).map { idx in
			   let dw = dailyFx[idx]
			   let symbolName = dw.symbolName
			   let minTemp = String(format: "%.0f", dw.lowTemperature.converted(to: .fahrenheit).value)
			   let maxTemp = String(format: "%.0f", dw.highTemperature.converted(to: .fahrenheit).value)
			   return Forecasts(symbolName: symbolName, minTemp: minTemp, maxTemp: maxTemp)
			}
		 } else {
			logAndPersist_external("[WeatherKit] dailyForecast => none found.")
		 }

	  } catch {
		 logAndPersist_external("[WeatherKit] getWeather => error: \(error.localizedDescription)")
		 if let e = error as? URLError, e.code == .notConnectedToInternet {
			logAndPersist_external("[WeatherKit] Network offline => isErrorAlert=true")
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
		 logAndPersist_external("[WeatherKit] dailyForecast => error: \(error.localizedDescription)")
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
		 logAndPersist_external("[WeatherKit] hourlyForecast => error: \(error.localizedDescription)")
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
