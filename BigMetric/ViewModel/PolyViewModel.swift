import SwiftUI
import HealthKit
import CoreLocation
import Combine

@MainActor
class PolyViewModel: ObservableObject, @unchecked Sendable {
   @Published var workouts: [HKWorkout] = []
   @Published var isLoading: Bool = false
   @Published var endDate: Date = Date()
   @Published var startDate: Date = Calendar.current.date(
	  byAdding: .day,
	  value: -30,
	  to: Date()
   ) ?? Date().addingTimeInterval(-30 * 24 * 3600)
   @Published var limit: Int = 45
   @Published var shortRouteFilter: Bool = false // default to off
   @Published var totalWorkoutCount: Int = 0
   @Published var filteredWorkoutCount: Int = 0

   /// Cache for city names keyed by workout UUID.
   private var cityNameCache: [UUID: String] = [:]

   /// Cache for entire route (coordinates) keyed by workout UUID.
   private var routeCache: [UUID: [CLLocationCoordinate2D]] = [:]

   /// Cache for computed or metadata-derived distance keyed by workout UUID.
   private var distanceCache: [UUID: Double] = [:]

   /// Cache for weather info keyed by workout UUID. (temp, symbol)
   private var weatherCache: [UUID: (String?, String?)] = [:]

   /// NEW: Cache for full CLLocation data, used to fetch timestamps.
   private var locationDataCache: [UUID: [CLLocation]] = [:]

   private let cacheQueue = DispatchQueue(label: "com.BigPoly.cacheQueue")

   private let healthStore = HKHealthStore()

   /// Common user-defined metadata keys you might store in the watch app
   private let METADATA_KEY_FINAL_DISTANCE = "finalDistance"
   private let METADATA_KEY_FINAL_DURATION = "finalDuration"
   private let METADATA_KEY_AVERAGE_SPEED  = "averageSpeed"
   private let METADATA_KEY_WEATHER_TEMP   = "weatherTemp"
   private let METADATA_KEY_WEATHER_SYMBOL = "weatherSymbol"
   private let METADATA_KEY_ENERGY_BURNED = "energyBurned"

   /// Call HealthKit permission as soon as this ViewModel is created to ensure compliance.
   init() {
	  Task {
		 do {
			try await requestHealthKitPermission()
		 } catch {
			print("HealthKit permission request failed: \(error)")
		 }
	  }
   }

   /// Request HealthKit authorization up front.
   func requestHealthKitPermission() async throws {
	  let typesToRead: Set<HKObjectType> = [
		 HKObjectType.workoutType(),
		 HKSeriesType.workoutRoute()
	  ]
	  try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
   }

   /// Loads workouts in pages, fetching more from HK to account for short-route filtering so we don't lose them all.
   func loadWorkouts(page: Int) {
	  guard !isLoading else { return }
	  isLoading = true

	  Task { [weak self] in
		 guard let self = self else { return }
		 do {
			// Fetch from HealthKit with a larger limit to compensate for any workouts we drop via filters.
			let bigLimit = self.limit * 5
			let rawWorkouts = try await self.fetchPagedWorkouts(
			   startDate: self.startDate,
			   endDate: self.endDate,
			   limit: bigLimit,
			   page: page
			)

			// If shortRouteFilter is on, exclude <0.1 mile workouts, but do it after we fetch enough from HK.
			var filtered: [HKWorkout] = []
			if self.shortRouteFilter {
			   for workout in rawWorkouts {
				  if let distance = await self.fetchDistance(for: workout), distance >= 0.1 {
					 filtered.append(workout)
				  }
			   }
			} else {
			   filtered = rawWorkouts
			}

			// Finally, keep only up to 'limit' of them for display.
			let displaySlice = Array(filtered.prefix(self.limit))

			await MainActor.run {
			   if page == 0 {
				  self.workouts = displaySlice
			   } else {
				  self.workouts.append(contentsOf: displaySlice)
			   }
			   self.isLoading = false
			}
		 } catch {
			await MainActor.run {
			   print("Failed to load workouts: \(error)")
			   self.isLoading = false
			}
		 }
	  }
   }

   /// Fetch distance from metadata if available; else route-based calculation.
   func fetchDistance(for workout: HKWorkout) async -> Double? {
	  if let cached = distanceCache[workout.uuid] {
		 return cached
	  }

	  print("DP - Checking METADATA for workout \(workout.uuid): META: \(String(describing: workout.metadata))")

	  // finalDistance can be stored as string or double
	  if let metaDistStr = workout.metadata?[METADATA_KEY_FINAL_DISTANCE] as? String,
		 let distDouble = Double(metaDistStr) {
		 print("DP - Found finalDistance as String: \(distDouble)")
		 distanceCache[workout.uuid] = distDouble
		 return distDouble
	  } else if let numericDist = workout.metadata?[METADATA_KEY_FINAL_DISTANCE] as? Double {
		 print("DP - Found finalDistance as Double: \(numericDist)")
		 distanceCache[workout.uuid] = numericDist
		 return numericDist
	  }

	  // fallback: compute from route
	  guard let coords = await fetchDetailedRouteData(for: workout), !coords.isEmpty else {
		 print("DP - No route coords or empty route for workout \(workout.uuid), distance = 0")
		 distanceCache[workout.uuid] = 0
		 return 0
	  }

	  let distance = coords.map { $0.location }.calcDistance
	  print("DP - Calculated distance from route: \(distance)")
	  distanceCache[workout.uuid] = distance
	  return distance
   }

   /// If watch wrote finalDuration in metadata, use it; else default to workout.duration
   func fetchDuration(for workout: HKWorkout) -> TimeInterval {
	  if let metaDurStr = workout.metadata?[METADATA_KEY_FINAL_DURATION] as? String,
		 let metaDurVal = Double(metaDurStr) {
		 print("DP - Found finalDuration as String: \(metaDurVal)")
		 return metaDurVal
	  }
	  if let metaDurDouble = workout.metadata?[METADATA_KEY_FINAL_DURATION] as? Double {
		 print("DP - Found finalDuration as Double: \(metaDurDouble)")
		 return metaDurDouble
	  }
	  print("DP - No finalDuration in metadata, using workout.duration: \(workout.duration)")
	  return workout.duration
   }

   /// If the watch wrote averageSpeed, read it. Otherwise return nil.
   func fetchAverageSpeed(for workout: HKWorkout) -> Double? {
	  if let metaSpeedStr = workout.metadata?[METADATA_KEY_AVERAGE_SPEED] as? String,
		 let metaSpeedVal = Double(metaSpeedStr) {
		 print("DP - Found averageSpeed as String: \(metaSpeedVal) mph")
		 return metaSpeedVal
	  }
	  if let metaSpeedDouble = workout.metadata?[METADATA_KEY_AVERAGE_SPEED] as? Double {
		 print("DP - Found averageSpeed as Double: \(metaSpeedDouble) mph")
		 return metaSpeedDouble
	  }
	  print("DP - No averageSpeed in metadata for workout \(workout.uuid)")
	  return nil
   }

   /// Fetch weather from metadata. If missing, attempt a fallback approach (currently none).
   func fetchWeather(for workout: HKWorkout) async -> (String?, String?)? {
	  if let cached = weatherCache[workout.uuid] {
		 if cached.0?.isEmpty == false && cached.1 != "xmark" {
			print("DP - Found valid weather in cache for \(workout.uuid): \(cached)")
			return cached
		 }
	  }

	  // If watch wrote weather metadata, validate it
	  let metaTemp = workout.metadata?[METADATA_KEY_WEATHER_TEMP] as? String
	  let metaSymbol = workout.metadata?[METADATA_KEY_WEATHER_SYMBOL] as? String

	  if let tempVal = metaTemp,
		 let symbolVal = metaSymbol,
		 !tempVal.isEmpty,
		 symbolVal != "xmark" {
		 print("DP - Found valid weather metadata => Temp: \(tempVal), Symbol: \(symbolVal)")
		 weatherCache[workout.uuid] = (tempVal, symbolVal)
		 return (tempVal, symbolVal)
	  }

	  print("DP - Invalid or missing weather data for \(workout.uuid)")
	  return nil
   }

   /// Returns the entire array of location data for the given workout, for time-based display, etc.
   func fetchFullLocationData(for workout: HKWorkout) async -> [CLLocation]? {
	  if let existing = locationDataCache[workout.uuid] {
		 return existing
	  }

	  guard let routes = await getWorkoutRoute(workout: workout), !routes.isEmpty else {
		 locationDataCache[workout.uuid] = []
		 return []
	  }

	  var fullData: [CLLocation] = []
	  for route in routes {
		 let locs = await getCLocationDataForRoute(routeToExtract: route)
		 fullData.append(contentsOf: locs)
	  }
	  locationDataCache[workout.uuid] = fullData
	  print("DP - fetchFullLocationData => Found \(fullData.count) location points for workout \(workout.uuid)")
	  return fullData
   }

   /// Return just the coordinate array (cached).
   func fetchDetailedRouteData(for workout: HKWorkout) async -> [CLLocationCoordinate2D]? {
	  if let cachedRoute = routeCache[workout.uuid] {
		 print("DP - Using cached route data for \(workout.uuid)")
		 return cachedRoute
	  }

	  guard let routes = await getWorkoutRoute(workout: workout),
			!routes.isEmpty else {
		 print("DP - No routes available for \(workout.uuid)")
		 return nil
	  }

	  var allCoordinates: [CLLocationCoordinate2D] = []
	  for route in routes {
		 let locations = await getCLocationDataForRoute(routeToExtract: route)
		 if !locations.isEmpty {
			allCoordinates.append(contentsOf: locations.map { $0.coordinate })
		 }
	  }

	  if allCoordinates.count >= 2 {
		 routeCache[workout.uuid] = allCoordinates
		 print("DP - Cached \(allCoordinates.count) coordinates for \(workout.uuid)")
		 return allCoordinates
	  }

	  print("DP - No valid coordinates found for \(workout.uuid)")
	  return nil
   }

   private func hasValidRouteData(_ workout: HKWorkout) async -> Bool {
	  print("\nDP - Checking route data for workout: \(workout.uuid)")
	  print("DP - Workout date: \(workout.startDate)")

	  guard let routes = await getWorkoutRoute(workout: workout),
			!routes.isEmpty else {
		 print("DP - No routes found")
		 return false
	  }

	  // Check if we can actually get coordinate data
	  for route in routes {
		 let locations = await getCLocationDataForRoute(routeToExtract: route)
		 if locations.count >= 2 { // Need at least 2 points for a valid route line
			print("DP - Found valid route with \(locations.count) locations")

			// Pre-cache the route data since we already have it
			let coordinates = locations.map { $0.coordinate }
			routeCache[workout.uuid] = coordinates

			return true
		 }
	  }

	  print("DP - No valid route data found")
	  return false
   }

   /// Adjusted strategy: we rely on a larger limit from the caller if short-route filtering is on,
   /// then we still only return up to 'limit' items from HK.
   func fetchPagedWorkouts(startDate: Date,
						   endDate: Date,
						   limit: Int,
						   page: Int) async throws -> [HKWorkout] {
	  let predicate = HKQuery.predicateForSamples(withStart: startDate,
												  end: endDate,
												  options: [.strictStartDate])
	  let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

	  print("\nDP - Fetching workouts between \(startDate) and \(endDate)")

	  let allWorkouts: [HKWorkout] = try await withCheckedThrowingContinuation { continuation in
		 let query = HKSampleQuery(sampleType: HKObjectType.workoutType(),
								   predicate: predicate,
								   limit: limit,
								   sortDescriptors: [sortDescriptor]) { [weak self] _, result, error in
			guard let self = self else {
			   continuation.resume(returning: [])
			   return
			}

			if let error = error {
			   continuation.resume(throwing: error)
			} else if let workouts = result as? [HKWorkout] {
			   Task { @MainActor in
				  self.totalWorkoutCount = workouts.count
			   }
			   print("DP - Initial HK query returned \(workouts.count) workouts")
			   continuation.resume(returning: workouts)
			} else {
			   continuation.resume(returning: [])
			}
		 }
		 self.healthStore.execute(query)
	  }

	  var validWorkouts: [HKWorkout] = []

	  for workout in allWorkouts {
		 if await hasValidRouteData(workout) {
			// Only apply distance filter if shortRouteFilter is enabled
			if self.shortRouteFilter {
			   if let distance = await fetchDistance(for: workout),
				  distance >= 0.1 {
				  validWorkouts.append(workout)
			   }
			} else {
			   validWorkouts.append(workout)
			}
		 } else {
			print("DP - Excluding workout \(workout.uuid) due to missing route data")
		 }
	  }

	  await MainActor.run {
		 self.filteredWorkoutCount = validWorkouts.count
	  }

	  print("\nDP - fetchPagedWorkouts summary:")
	  print("- Total workouts found: \(self.totalWorkoutCount)")
	  print("- Workouts with valid routes: \(self.filteredWorkoutCount)")
	  print("- Filtered out: \(self.totalWorkoutCount - self.filteredWorkoutCount)")

	  return validWorkouts
   }

   /// Fetches route objects from HealthKit for a given workout.
   func getWorkoutRoute(workout: HKWorkout) async -> [HKWorkoutRoute]? {
	  let byWorkout = HKQuery.predicateForObjects(from: workout)
	  let samples = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
		 healthStore.execute(
			HKAnchoredObjectQuery(
			   type: HKSeriesType.workoutRoute(),
			   predicate: byWorkout,
			   anchor: nil,
			   limit: HKObjectQueryNoLimit
			) { _, samples, _, _, error in
			   if let error = error {
				  continuation.resume(throwing: error)
				  return
			   }
			   let s = samples ?? []
			   continuation.resume(returning: s)
			}
		 )
	  }
	  guard let workouts = samples as? [HKWorkoutRoute] else {
		 print("\nDP - getWorkoutRoute => no HKWorkoutRoute found for \(workout.uuid)")
		 return nil
	  }
	  print("\nDP - getWorkoutRoute => \(workouts.count) route(s) for \(workout.uuid)")
	  return workouts
   }

   /// Fetches the CLLocation data from a single HKWorkoutRoute
   func getCLocationDataForRoute(routeToExtract: HKWorkoutRoute) async -> [CLLocation] {
	  do {
		 let locations: [CLLocation] = try await withCheckedThrowingContinuation { continuation in
			var allLocations: [CLLocation] = []
			let query = HKWorkoutRouteQuery(route: routeToExtract) { _, locsOrNil, done, errOrNil in
			   if let err = errOrNil {
				  continuation.resume(throwing: err)
				  return
			   }
			   if let locsOrNil = locsOrNil {
				  allLocations.append(contentsOf: locsOrNil)
				  if done {
					 continuation.resume(returning: allLocations)
				  }
			   } else {
				  continuation.resume(returning: [])
			   }
			}
			self.healthStore.execute(query)
		 }
		 return locations
	  } catch {
		 print("Error fetching location data: \(error.localizedDescription)")
		 return []
	  }
   }

   private func getCachedCity(for uuid: UUID) -> String? {
	  cacheQueue.sync { cityNameCache[uuid] }
   }

   private func setCachedCity(_ city: String, for uuid: UUID) {
	  cacheQueue.sync { cityNameCache[uuid] = city }
   }

   /// Gets city name from cache or fallback geocoding
   func fetchCityName(for workout: HKWorkout) async -> String? {
	  if let cachedCity = getCachedCity(for: workout.uuid) {
		 return cachedCity
	  }

	  guard let routes = await getWorkoutRoute(workout: workout),
			let route = routes.first else {
		 setCachedCity("Unknown City", for: workout.uuid)
		 return "Unknown City"
	  }

	  let locations = await getCLocationDataForRoute(routeToExtract: route)
	  guard let firstLocation = locations.first else {
		 setCachedCity("Unknown City", for: workout.uuid)
		 return "Unknown City"
	  }

	  let geocoder = CLGeocoder()
	  do {
		 let placemarks = try await geocoder.reverseGeocodeLocation(firstLocation)
		 let city = placemarks.first?.locality ?? "Unknown City"
		 setCachedCity(city, for: workout.uuid)
		 return city
	  } catch {
		 print("Address not found: \(error.localizedDescription)")
		 setCachedCity("Unknown City", for: workout.uuid)
		 return "Unknown City"
	  }
   }

   func fetchEnergyBurned(for workout: HKWorkout) -> Double? {
	  // First check metadata
	  if let metaEnergyStr = workout.metadata?[METADATA_KEY_ENERGY_BURNED] as? String,
		 let energyValue = Double(metaEnergyStr) {
		 print("DP - Found energyBurned as String: \(energyValue)")
		 return energyValue
	  }

	  // Then check workout's direct energy burned property
	  if #available(iOS 18.0, *) {
		 if let statistics = workout.statistics(for: HKQuantityType(.activeEnergyBurned)),
			let energy = statistics.sumQuantity()?.doubleValue(for: .kilocalorie()) {
			print("DP - Found energyBurned from workout statistics: \(energy)")
			return energy
		 }
	  } else {
		 if let energy = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) {
			print("DP - Found energyBurned from workout: \(energy)")
			return energy
		 }
	  }

	  print("DP - No energyBurned found for workout \(workout.uuid)")
	  return nil
   }

   func fetchHeartRateStats(for workout: HKWorkout) -> (avg: Double?, min: Double?, max: Double?)? {
	  if #available(iOS 18.0, *) {
		 if let heartRateStats = workout.statistics(for: HKQuantityType(.heartRate)) {
			let avg = heartRateStats.averageQuantity()?.doubleValue(for: .count().unitDivided(by: .minute()))
			let min = heartRateStats.minimumQuantity()?.doubleValue(for: .count().unitDivided(by: .minute()))
			let max = heartRateStats.maximumQuantity()?.doubleValue(for: .count().unitDivided(by: .minute()))
			return (avg, min, max)
		 }
	  }
	  return nil
   }
}
