//   WorkoutCore.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/8/24 at 9:58 AM
//     Modified:
//
//  Copyright 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI
import HealthKit
import CoreLocation
import Observation

@Observable
public class WorkoutCore: @unchecked Sendable {
   public static let shared = WorkoutCore()
   public var distance: Double = 0
   private let healthStore = HKHealthStore()
   public var cityNames: [UUID: String] = [:] // Maps workout UUID to city names
   
   private init() {}
   
   // Requests permission to access HealthKit data.
   public func requestHealthKitPermission() async throws {
	  let typesToRead: Set<HKObjectType> = [
		 HKObjectType.workoutType(),
		 HKSeriesType.workoutRoute(),
		 HKQuantityType(.heartRate),
		 HKQuantityType(.heartRateVariabilitySDNN),
		 HKQuantityType(.activeEnergyBurned),
		 HKQuantityType(.distanceWalkingRunning),
		 HKQuantityType(.stepCount),
		 HKQuantityType(.runningSpeed),
		 HKQuantityType(.runningPower),
		 HKQuantityType(.walkingSpeed),
		 HKQuantityType(.runningStrideLength),
		 HKQuantityType(.walkingStepLength),
		 HKQuantityType(.runningGroundContactTime),
		 HKQuantityType(.runningVerticalOscillation)
	  ]
	  
	  try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
   }
   
   public func fetchLastWorkouts(limit: Int) async throws -> [HKWorkout] {
	  let predicate = HKQuery.predicateForWorkouts(with: .walking)
	  let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
	  
	  // Fetch all workouts first
	  let allWorkouts: [HKWorkout] = try await withCheckedThrowingContinuation { continuation in
		 let query = HKSampleQuery(sampleType: HKObjectType.workoutType(),
								   predicate: predicate,
								   limit: limit,
								   sortDescriptors: [sortDescriptor]) { _, result, error in
			if let error = error {
			   continuation.resume(throwing: error)
			} else if let workouts = result as? [HKWorkout] {
			   continuation.resume(returning: workouts)
			} else {
			   continuation.resume(returning: [])
			}
		 }
		 self.healthStore.execute(query)
	  }
	  
	  // Filter workouts that have route data with valid coordinates
	  var workoutsWithValidCoordinates: [HKWorkout] = []
	  for workout in allWorkouts {
		 // Fetch routes for each workout
		 if let routes = await getWorkoutRoute(workout: workout), !routes.isEmpty {
			// Check for valid coordinates in each route
			for route in routes {
			   let locations = await getCLocationDataForRoute(routeToExtract: route)
			   if locations.contains(where: { $0.coordinate.latitude != 0 && $0.coordinate.longitude != 0 }) {
				  workoutsWithValidCoordinates.append(workout)
				  break // Found valid coordinates, no need to check further routes
			   }
			}
		 }
	  }
	  
	  return workoutsWithValidCoordinates
   }
   
   
   // Fetches the last specified number of workouts.
   //	func fetchLastWorkouts(limit: Int) async throws -> [HKWorkout] {
   //		let predicate = HKQuery.predicateForWorkouts(with: .walking)
   //		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
   //
   //		return try await withCheckedThrowingContinuation { continuation in
   //			let query = HKSampleQuery(sampleType: HKObjectType.workoutType(),
   //											  predicate: predicate,
   //											  limit: limit,
   //											  sortDescriptors: [sortDescriptor]) { _, result, error in
   //				if let error = error {
   //					continuation.resume(throwing: error)
   //				} else if let workouts = result as? [HKWorkout] {
   //					continuation.resume(returning: workouts)
   //				} else {
   //					continuation.resume(returning: [])
   //				}
   //			}
   //			self.healthStore.execute(query)
   //		}
   //	}
   
   // Fetches route data for a given workout and returns the coordinates.
   public func fetchRouteData(for workout: HKWorkout) async throws -> [CLLocationCoordinate2D] {
	  // Directly use HKSeriesType.workoutRoute() since it's non-optional
	  let routeType = HKSeriesType.workoutRoute()
	  
	  // Fetch routes
	  let routes: [HKWorkoutRoute] = try await withCheckedThrowingContinuation { continuation in
		 let predicate = HKQuery.predicateForObjects(from: workout)
		 let query = HKSampleQuery(sampleType: routeType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
			if let error = error {
			   continuation.resume(throwing: error)
			} else if let routes = samples as? [HKWorkoutRoute] {
			   continuation.resume(returning: routes)
			} else {
			   // It's crucial to resume the continuation even if no routes are found to avoid hanging.
			   continuation.resume(returning: [])
			}
		 }
		 self.healthStore.execute(query)
	  }
	  
	  // Ensure there's at least one route to process
	  guard let firstRoute = routes.first else {
		 return []
	  }
	  
	  // Proceed to fetch and process coordinates from the first route
	  return try await fetchCoordinates(for: firstRoute)
   }
   
   // Helper function to fetch coordinates for a route.
   public func fetchCoordinates(for route: HKWorkoutRoute) async throws -> [CLLocationCoordinate2D] {
	  try await withCheckedThrowingContinuation { continuation in
		 var coordinates: [CLLocationCoordinate2D] = []
		 
		 let query = HKWorkoutRouteQuery(route: route) { _, returnedLocations, done, errorOrNil in
			if let error = errorOrNil {
			   continuation.resume(throwing: error)
			   return
			}
			
			if let locations = returnedLocations {
			   coordinates.append(contentsOf: locations.map { $0.coordinate })
			}
			
			if done {
			   continuation.resume(returning: coordinates)
			}
		 }
		 
		 healthStore.execute(query)
	  }
   }
   
   public func getWorkoutDistance(_ thisWorkout: HKWorkout) async throws -> Double {
	  guard let route = await getWorkoutRoute(workout: thisWorkout)?.first else {
		 return 0
	  }
	  // get the coordinates of the last workout
	  let coords = await getCLocationDataForRoute(routeToExtract: route)
	  //		var longitude = coords.last?.coordinate.longitude
	  //		var latitude = coords.last?.coordinate.latitude
	  return coords.calcDistance
	  //		return await getCLocationDataForRoute(routeToExtract: route).calcDistance
   }
   
   public func formatDuration(duration: TimeInterval) -> String {
	  let formatter = DateComponentsFormatter()
	  formatter.unitsStyle = .positional
	  formatter.allowedUnits = [.minute, .second]
	  formatter.zeroFormattingBehavior = .pad
	  
	  if duration >= 3600 { // if duration is 1 hour or longer
		 formatter.allowedUnits.insert(.hour)
	  }
	  
	  return formatter.string(from: duration) ?? "0:00"
   }
   
   public func formatDateName(_ date: Date) -> String {
	  let dateFormatter = DateFormatter()
	  dateFormatter.dateFormat = "MMMM d, yyyy"
	  return dateFormatter.string(from: date)
   }
   
   public func getWorkoutRoute(workout: HKWorkout) async -> [HKWorkoutRoute]? {
	  let byWorkout 	= HKQuery.predicateForObjects(from: workout)
	  let samples 	= try! await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
		 healthStore.execute(HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(),
												   predicate: byWorkout,
												   anchor: nil,
												   limit: HKObjectQueryNoLimit,
												   resultsHandler: { (query, samples, deletedObjects, anchor, error) in
			if let hasError = error {
			   continuation.resume(throwing: hasError)
			   return
			}
			guard let samples = samples else { return }
			continuation.resume(returning: samples)
		 }))
	  }
	  guard let workouts = samples as? [HKWorkoutRoute] else { return nil }
	  return workouts
   }
   
   private func logAndPersist(_ message: String) {
	  // If UnifiedWorkoutManager.shared available, could delegate there.
	  let timestamp = ISO8601DateFormatter().string(from: Date())
	  let entry = "[\(timestamp)] \(message)"
	  var logs = UserDefaults.standard.stringArray(forKey: "logHistory") ?? []
	  logs.append(entry)
	  UserDefaults.standard.set(Array(logs.suffix(250)), forKey: "logHistory")
#if DEBUG
	  print(message)
#endif
   }
   
   public func getCLocationDataForRoute(routeToExtract: HKWorkoutRoute) async -> [CLLocation] {
	  do {
		 let locations: [CLLocation] = try await withCheckedThrowingContinuation { continuation in
			var allLocations: [CLLocation] = []
			let query = HKWorkoutRouteQuery(route: routeToExtract) { query, locationsOrNil, done, errorOrNil in
			   if let error = errorOrNil {
				  self.logAndPersist("Error fetching location data: \(error.localizedDescription)")
				  continuation.resume(throwing: error)
				  return
			   }
			   if let locationsOrNil = locationsOrNil {
				  allLocations.append(contentsOf: locationsOrNil)
				  if done {
					 continuation.resume(returning: allLocations)
				  }
			   } else {
				  continuation.resume(returning: []) // Resume with an empty array if no locations are found
			   }
			}
			healthStore.execute(query)
		 }
		 return locations
	  } catch {
		 logAndPersist("Error fetching location data: \(error.localizedDescription)")
		 return []
	  }
   }
   
   public func calcNumCoords(_ work: HKWorkout) async -> Int {
	  guard let route = await getWorkoutRoute(workout: work)?.first else {
		 return 0
	  }
	  let locations = await getCLocationDataForRoute(routeToExtract: route)
	  let filteredLocations = locations.filter { $0.coordinate.latitude != 0 || $0.coordinate.longitude != 0 }
	  return filteredLocations.count
   }
   
   public func filterWorkoutsWithCoords(_ workouts: [HKWorkout]) async -> [HKWorkout] {
	  var filteredWorkouts: [HKWorkout] = []
	  for workout in workouts {
		 if await calcNumCoords(workout) > 0 {
			filteredWorkouts.append(workout)
		 }
	  }
	  return filteredWorkouts
   }
   
   public func fetchPagedWorkouts(startDate: Date, endDate: Date, limit: Int, page: Int) async throws -> [HKWorkout] {
	  let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
	  let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
	  
	  // Fetch workouts
	  let allWorkouts: [HKWorkout] = try await withCheckedThrowingContinuation { continuation in
		 let query = HKSampleQuery(sampleType: HKObjectType.workoutType(),
								   predicate: predicate,
								   limit: limit, // Assuming pagination is handled externally
								   sortDescriptors: [sortDescriptor]) { _, result, error in
			if let error = error {
			   continuation.resume(throwing: error)
			} else if let workouts = result as? [HKWorkout] {
			   continuation.resume(returning: workouts)
			} else {
			   continuation.resume(returning: [])
			}
		 }
		 self.healthStore.execute(query)
	  }
	  
	  // Filter workouts with valid route data
	  var filteredWorkouts: [HKWorkout] = []
	  for workout in allWorkouts {
		 if let routes = await getWorkoutRoute(workout: workout), !routes.isEmpty {
			for route in routes {
			   let locations = await getCLocationDataForRoute(routeToExtract: route)
			   if !locations.isEmpty && locations.contains(where: { $0.coordinate.latitude != 0 && $0.coordinate.longitude != 0 }) {
				  filteredWorkouts.append(workout)
				  break // Found valid coordinates, no need to check further routes
			   }
			}
		 }
	  }
	  
	  return filteredWorkouts
   }
   
   public func updateCityName(for workoutID: UUID, with cityName: String) {
	  DispatchQueue.main.async {
		 self.cityNames[workoutID] = cityName
	  }
   }
   
   public func cityName(for workoutID: UUID) -> String {
	  self.cityNames[workoutID] ?? "Unknown City"
   }
   
   public func update(from workout: HKWorkout) {
	  // Basic metrics
	  self.distance = workout.totalDistance?.doubleValue(for: .mile()) ?? 0.0
	  
	  // Heart Rate
	  if let heartRateStats = workout.statistics(for: HKQuantityType(.heartRate)) {
		 logAndPersist("[WorkoutCore] Heart Rate Avg: \(heartRateStats.averageQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())) ?? 0) bpm")
		 logAndPersist("[WorkoutCore] Heart Rate Min: \(heartRateStats.minimumQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())) ?? 0) bpm")
		 logAndPersist("[WorkoutCore] Heart Rate Max: \(heartRateStats.maximumQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())) ?? 0) bpm")
	  }
	  
	  // Steps & Cadence
	  if let stepsStats = workout.statistics(for: HKQuantityType(.stepCount)) {
		 logAndPersist("[WorkoutCore] Steps: \(stepsStats.sumQuantity()?.doubleValue(for: .count()) ?? 0)")
	  }
	  
	  // Running Dynamics
	  if let strideStats = workout.statistics(for: HKQuantityType(.runningStrideLength)) {
		 logAndPersist("[WorkoutCore] Stride Length: \(strideStats.averageQuantity()?.doubleValue(for: .meter()) ?? 0) m")
	  }
	  
	  if let groundContactStats = workout.statistics(for: HKQuantityType(.runningGroundContactTime)) {
		 // Convert to milliseconds from seconds
		 let seconds = groundContactStats.averageQuantity()?.doubleValue(for: .second()) ?? 0
		 let milliseconds = seconds * 1000
		 logAndPersist("[WorkoutCore] Ground Contact Time: \(milliseconds) ms")
	  }
	  
	  if let verticalOscStats = workout.statistics(for: HKQuantityType(.runningVerticalOscillation)) {
		 // Convert to centimeters for better readability
		 let centimeters = (verticalOscStats.averageQuantity()?.doubleValue(for: .meter()) ?? 0) * 100
		 logAndPersist("[WorkoutCore] Vertical Oscillation: \(centimeters) cm")
	  }
	  
	  // Energy
	  if let energyStats = workout.statistics(for: HKQuantityType(.activeEnergyBurned)) {
		 logAndPersist("[WorkoutCore] Energy burned: \(energyStats.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0) kcal")
	  }
   }
   
   public func fetchEnergyBurned(for workout: HKWorkout) async -> Double? {
	  let energyType = HKQuantityType(.activeEnergyBurned)
	  
	  // Create the predicate for the specific workout
	  let predicate = HKQuery.predicateForObjects(from: workout)
	  
	  // Create and execute the query
	  return try? await withCheckedThrowingContinuation { continuation in
		 let query = HKSampleQuery(
			sampleType: energyType,
			predicate: predicate,
			limit: HKObjectQueryNoLimit,
			sortDescriptors: nil
		 ) { _, samples, error in
			if let error = error {
			   print("Error fetching energy burned: \(error)")
			   continuation.resume(returning: nil)
			   return
			}
			
			// Sum up all the energy samples
			let totalEnergy = samples?.reduce(0.0) { total, sample in
			   guard let quantity = (sample as? HKQuantitySample)?.quantity else { return total }
			   return total + quantity.doubleValue(for: .kilocalorie())
			}
			
			continuation.resume(returning: totalEnergy)
		 }
		 
		 healthStore.execute(query)
	  }
   }
   
}
