import SwiftUI
import Foundation
import CoreMotion
import CoreLocation
import HealthKit
import WatchConnectivity
import Observation
import UserNotifications

/// UnifiedWorkoutManager is responsible for managing the workout session, handling location updates,
/// HealthKit workout sessions, and route data insertion.
@Observable
class UnifiedWorkoutManager: NSObject,
							 CLLocationManagerDelegate,
							 HKWorkoutSessionDelegate,
							 HKLiveWorkoutBuilderDelegate,
							 ObservableObject,
							 @unchecked Sendable {

   // MARK: - Public Properties

   /// A callback so the UI can show summary after finishing
   var onEndAndShowSummary: (() -> Void)?

   var workoutFullySaved: Bool = false
   var isSavingToHealthKit: Bool = false
   var workoutState: WorkoutState = .notStarted

   let healthStore = HKHealthStore()
   var session: HKWorkoutSession?
   var builder: HKLiveWorkoutBuilder?
   var routeBuilder: HKWorkoutRouteBuilder?

   var distance: Double = 0.0
   var lastHapticMile: Int = 0
   var workoutStepCount: Int = 0

   var weatherKitManager: WeatherKitManager
   var geoCodeHelper: GeoCodeHelper

   var locationName: String = "Unknown"
   var weatherTemp: String = "--"
   var weatherSymbol: String = ""

   var weIsRecording: Bool = false
   var isLocateMgr: Bool = false
   var isBeep: Bool = true
   var isSpeed: Bool = true
   var showStartText: Bool = true
   var isPrecise: Bool = true
   var yardsOrMiles: Bool = true
   var hotColdFirst: Bool = false

   let pedometer = CMPedometer()
   var holdInitialSteps: Int = 0

   var GPSAccuracy = 99.0
   let metersToFeet  = 0.3048
   let metersToMiles = 1609.344
   let metersToYards = 1.0936133

   var timer: Timer?
   var elapsedTime: Double = 0
   var formattedTimeString: String = "00:00"
   var isTimerPaused: Bool = false

   var heartRate: Double = 0 {
	  didSet { heartRateReadings.append(heartRate) }
   }

   public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
	  // If the heading is invalid, just return
	  guard newHeading.headingAccuracy >= 0 else {
		 return
	  }

	  // Use trueHeading if >= 0, else fall back to magnetic
	  let updatedCourse = (newHeading.trueHeading >= 0)
	  ? newHeading.trueHeading
	  : newHeading.magneticHeading

	  course = updatedCourse

	  // Use the defined static method on CardinalDirection
	  heading = CardinalDirection.from(degrees: updatedCourse).rawValue
   }
   var heartRateReadings: [Double] = []

   var LMDelegate = CLLocationManager()
   var locationsArray: [CLLocation] = []
   var altitudes: [AltitudeDataPoint] = []
   var lastLocation: CLLocation?
   var firstLocation: CLLocation?

   var isInitialLocationObtained: Bool = false
   var ShowEstablishGPSScreen: Bool = true
   var debugStr: String = ""

   var heading: String = "0"
   var course: Double = 0.0

   private var consecutiveHighSpeedPoints = 0
   private let maxHighSpeedConsecutive = 2
   private var isShowingDrivingAlert = false
   var lastValidLocationIndex: Int?
   var savedHapticState: Bool = false
   var shouldInsertRouteData: Bool = true

   var activityTypeChoice: ActivityTypeSetup = .walk
   var chosenActivityType: HKWorkoutActivityType = .walking
   var maxSpeedMph: Double = 20.0

   var shouldFinishWorkoutAfterSessionEnd: Bool = false

   var energyBurned: Double = 0

   private let activityManager = CMMotionActivityManager()
   private var bufferedLocations: [CLLocation] = []
   private var bufferingTimer: Timer?
   private var promptDismissTimer: Timer?

   // MARK: Walking Trigger

   private let alertAutoDismissTime: TimeInterval = 120
   private let maxBufferingTime: TimeInterval = 300
   private let activityDetectionThreshold: TimeInterval = 120
   private var userDeclinedCurrentActivity: Bool = false
   var isWalkingTriggerOn: Bool = false

   // MARK: - Initialization

   init(weatherKitManager: WeatherKitManager = WeatherKitManager(),
		geoCodeHelper: GeoCodeHelper = GeoCodeHelper()) {

	  self.weatherKitManager = weatherKitManager
	  self.geoCodeHelper = geoCodeHelper
	  super.init()
	  resetForNewWorkout()
	  setPrecision()
	  //  	  LMDelegate.allowsBackgroundLocationUpdates = true
	  LMDelegate.activityType = .fitness

	  setupWorkoutNotificationActions()
	  startMonitoringActivity()
	  isWalkingTriggerOn = true
   }

   // MARK: - Weather and Location Updates

   private func setupWorkoutNotificationActions() {
	  let startWorkoutAction = UNNotificationAction(
		 identifier: "START_WORKOUT",
		 title: "✅ Start Workout",
		 options: [.foreground]
	  )

	  let ignoreWorkoutAction = UNNotificationAction(
		 identifier: "IGNORE_WORKOUT",
		 title: "❌ Ignore",
		 options: []
	  )

	  let category = UNNotificationCategory(
		 identifier: "WORKOUT_DETECTED",
		 actions: [startWorkoutAction, ignoreWorkoutAction],
		 intentIdentifiers: [],
		 options: []
	  )

	  UNUserNotificationCenter.current().setNotificationCategories([category])
   }

   /// Updates weather info using the WeatherKitManager.
   func updateWeatherInfo(from weatherKitManager: WeatherKitManager) {
	  locationName  = weatherKitManager.locationName
	  weatherTemp   = weatherKitManager.tempVar
	  weatherSymbol = weatherKitManager.symbolVar
	  print("[UWM] Weather updated => city=\(locationName), temp=\(weatherTemp), symbol=\(weatherSymbol)")
   }

   /// Asynchronously fetch weather and city information if needed.
   func fetchWeatherAndCityIfNeeded() async {
	  guard locationName == "Unknown" || weatherTemp == "--" else { return }
	  guard let finalLoc = locationsArray.last else {
		 print("[UWM] No location data => can't do fallback weather.")
		 return
	  }

	  let coord = finalLoc.coordinate
	  print("[UWM] fallback => attempting city geocode & WeatherKit for coord:\(coord)")

	  await withCheckedContinuation { continuation in
		 geoCodeHelper.getCityNameFromCoordinates(coord.latitude, coord.longitude) { placemark in
			if let place = placemark {
			   self.locationName = place.locality ?? "Unknown"
			}
			continuation.resume(returning: ())
		 }
	  }

	  await weatherKitManager.getWeather(for: coord)
	  updateWeatherInfo(from: weatherKitManager)
	  print("[UWM] fallback => got city=\(locationName), temp=\(weatherTemp), symbol=\(weatherSymbol)")
   }

   // MARK: - Workout Session Management

   /// Starts a new workout session.
   func startNewWorkout() {
	  resetForNewWorkout()
	  LMDelegate.delegate = self
	  clearBufferedLocations() // Explicitly clear buffered locations before initializing workout

	  chosenActivityType = activityTypeChoice.hkActivityType
	  maxSpeedMph = activityTypeChoice.maxSpeed

	  requestHKAuth()

	  let config = HKWorkoutConfiguration()
	  config.activityType = chosenActivityType
	  config.locationType = .outdoor

	  do {
		 session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
		 builder = session?.associatedWorkoutBuilder()
		 session?.delegate = self
		 builder?.delegate = self
		 builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)

		 session?.prepare()

		 let startDate = Date()
		 session?.startActivity(with: startDate)
		 builder?.beginCollection(withStart: startDate) { _, _ in
			print("[UWM] beginCollection => collection started")
		 }

		 routeBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: nil)
	  } catch {
		 print("Error starting HKWorkoutSession: \(error.localizedDescription)")
		 return
	  }

	  // Cancel automatic workout detection since the user manually started a workout.
	  userDeclinedCurrentActivity = true

	  weIsRecording = true
	  LMDelegate.startUpdatingLocation()
	  LMDelegate.startUpdatingHeading()
	  startPedometer(true)
	  startTimer()
   }

   /// Stops and finishes the workout, saving data to HealthKit.
   ///
   /// This method now sets a flag to indicate that the workout should be finished once the session
   /// has fully ended. It then calls endCurrentWorkout() to end the session.
   func stopAndFinish() {
	  // Stop activity monitoring immediately
	  activityManager.stopActivityUpdates()
	  userDeclinedCurrentActivity = false
	  isWalkingTriggerOn = false

	  isSavingToHealthKit = true
	  shouldFinishWorkoutAfterSessionEnd = true
	  endCurrentWorkout()

	  // Clear any buffered locations immediately
	  clearBufferedLocations()

	  DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
		 guard let self = self else { return }
		 if self.isSavingToHealthKit && self.shouldFinishWorkoutAfterSessionEnd {
			print("[UWM] Safety timeout reached - forcing workout completion")
			self.finishWorkoutAndRoute()
			self.shouldFinishWorkoutAfterSessionEnd = false
		 }
	  }
   }

   /// Ends the current workout.
   func endCurrentWorkout() {
	  session?.end()
	  LMDelegate.stopUpdatingLocation()
	  stopPedometer()
	  workoutState = .ended
   }

   /// Finishes the workout and the route, writing data to HealthKit.
   // FIX: Improve the finishWorkoutAndRoute method to handle errors better
   /// Finishes the workout and the route, writing data to HealthKit.
   func finishWorkoutAndRoute() {
	  guard !workoutFullySaved else {
		 print("[UWM] Workout already saved, ignoring duplicate finishWorkoutAndRoute call")
		 isSavingToHealthKit = false
		 return
	  }

	  guard let thisBuilder = builder else {
		 print("[UWM] No workout builder available, cannot finish workout")
		 isSavingToHealthKit = false
		 return
	  }

	  Task {
		 do {
			// End collection and await result using async extension
			try await thisBuilder.endCollectionAsync(withEnd: Date())
			print("[UWM] Collection ended successfully")

			// ENHANCE: Weather data validation and fetching
			if locationName == "Unknown" || weatherTemp == "--" || weatherSymbol.isEmpty {
			   if let lastLocation = locationsArray.last {
				  print("[UWM] Missing weather data - fetching from last waypoint")
				  await weatherKitManager.getWeather(for: lastLocation.coordinate)

				  // Get location name if missing
				  if locationName == "Unknown" {
					 await withCheckedContinuation { continuation in
						geoCodeHelper.getCityNameFromCoordinates(
						   lastLocation.coordinate.latitude,
						   lastLocation.coordinate.longitude
						) { placemark in
						   if let place = placemark {
							  self.locationName = place.locality ?? "Unknown"
						   }
						   continuation.resume(returning: ())
						}
					 }
				  }

				  updateWeatherInfo(from: weatherKitManager)
				  print("[UWM] Weather data updated: city=\(locationName), temp=\(weatherTemp), symbol=\(weatherSymbol)")
			   }
			}

			let meta = buildMetadataDictionary()

			// Rest of the existing code remains the same...
			try await thisBuilder.addMetadataAsync(meta)
			print("[UWM] Metadata added successfully")

			// Existing workout finishing code...

			let workout = try await thisBuilder.finishWorkoutAsync()
			print("[UWM] Workout finished successfully: \(workout.uuid)")

			if let routeBuilder = self.routeBuilder, !self.locationsArray.isEmpty {
			   try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
				  routeBuilder.insertRouteData(self.locationsArray) { success, error in
					 if let error = error {
						continuation.resume(throwing: error)
					 } else if success {
						continuation.resume()
					 } else {
						continuation.resume(throwing: NSError(domain: "RouteInsertFailed", code: 1, userInfo: nil))
					 }
				  }
			   }
			   print("[UWM] Inserted \(self.locationsArray.count) locations into route before finishing.")
			}

			if let routeBuilder = self.routeBuilder {
			   try await routeBuilder.finishRouteAsync(with: workout, metadata: nil)
			   print("[UWM] Route successfully added to workout: \(workout.uuid)")
			}

			self.workoutFullySaved = true
			self.isSavingToHealthKit = false

			DispatchQueue.main.async {
			   print("[UWM] Calling onEndAndShowSummary callback")
			   self.onEndAndShowSummary?()
			}

			self.startMonitoringActivity()
			self.isWalkingTriggerOn = true

		 } catch {
			print("[UWM] Error finishing workout: \(error.localizedDescription)")
			self.isSavingToHealthKit = false

			DispatchQueue.main.async {
			   self.workoutFullySaved = true
			   self.onEndAndShowSummary?()
			}
		 }
	  }
   }

   /// Builds a metadata dictionary for the workout.
   private func buildMetadataDictionary() -> [String: Any] {
	  let finalDistance = distance
	  let finalDuration = elapsedTime
	  var averageSpeed: Double = 0
	  if finalDuration > 0 {
		 averageSpeed = finalDistance / (finalDuration / 3600.0)
	  }
	  let meta: [String: Any] = [
		 "finalDistance": String(format: "%.3f", finalDistance),
		 "finalDuration": String(format: "%.0f", finalDuration),
		 "averageSpeed":  String(format: "%.2f", averageSpeed),
		 "stepCount":     String(workoutStepCount),
		 "weatherCity":   locationName,
		 "weatherTemp":   weatherTemp,
		 "weatherSymbol": weatherSymbol,
		 "energyBurned": String(format: "%.0f", energyBurned)  // Add this line
	  ]
	  print("[UWM] buildMetadataDictionary => \(meta)")
	  return meta
   }

   /// Resets all data for a new workout session.
   func resetForNewWorkout() {
	  // Add safety check to stop activity monitoring first
	  stopAllLocationUpdates()
	  activityManager.stopActivityUpdates()
	  userDeclinedCurrentActivity = false
	  isWalkingTriggerOn = false

	  timer?.invalidate()
	  timer = nil

	  workoutStepCount = 0
	  holdInitialSteps = 0
	  locationsArray.removeAll()
	  altitudes.removeAll()
	  lastLocation = nil
	  firstLocation = nil
	  consecutiveHighSpeedPoints = 0
	  isShowingDrivingAlert = false
	  lastValidLocationIndex = nil
	  lastHapticMile = 0

	  elapsedTime = 0
	  formattedTimeString = "00:00"

	  routeBuilder = nil
	  session = nil
	  builder = nil
	  workoutFullySaved = false
	  weIsRecording = false
	  workoutState = .notStarted

	  isInitialLocationObtained = false
	  ShowEstablishGPSScreen = true
	  isLocateMgr = false
	  heading = "0"
	  course = 0.0
	  distance = 0.0
	  shouldInsertRouteData = true

	  locationName = "Unknown"
	  weatherTemp = "--"
	  weatherSymbol = ""
	  energyBurned = 0

	  isSavingToHealthKit = false

	  // Clear any buffered locations and timers
	  clearBufferedLocations()
	  bufferingTimer?.invalidate()
	  promptDismissTimer?.invalidate()

	  // Reset location manager properties
	  LMDelegate.desiredAccuracy = kCLLocationAccuracyThreeKilometers
	  LMDelegate.desiredAccuracy = isPrecise ? kCLLocationAccuracyBest : kCLLocationAccuracyNearestTenMeters
	  GPSAccuracy = 99.0

	  print("resetForNewWorkout => data cleared, fresh session, location updates stopped.")
   }

   // MARK: - Pedometer

   /// Stops pedometer updates.
   func stopPedometer() {
	  pedometer.stopUpdates()
	  pedometer.stopEventUpdates()
   }

   /// Starts pedometer updates.
   func startPedometer(_ startStop: Bool) {
	  if CMPedometer.isStepCountingAvailable() {
		 if startStop {
			let midnight = Calendar.current.startOfDay(for: Date())
			pedometer.queryPedometerData(from: midnight, to: Date()) { [weak self] data, err in
			   guard let self = self else { return }
			   if let d = data {
				  let initialSteps = Int(truncating: d.numberOfSteps)
				  print("[Pedometer] Initial steps: \(initialSteps)")
				  self.holdInitialSteps = initialSteps

				  self.pedometer.startUpdates(from: midnight) { [weak self] stepData, _ in
					 guard let self = self else { return }
					 if let stepData = stepData {
						let currentSteps = Int(truncating: stepData.numberOfSteps)
						self.workoutStepCount = currentSteps - self.holdInitialSteps
					 }
				  }
			   }
			}
		 } else {
			stopPedometer()
		 }
	  }
   }

   /// Sets location manager precision.
   func setPrecision() {
	  LMDelegate.distanceFilter = isPrecise ? 1 : 10
	  LMDelegate.desiredAccuracy = isPrecise ? kCLLocationAccuracyBest : kCLLocationAccuracyNearestTenMeters
   }

   // MARK: - Location Manager Delegate

   /// Updates location data and filters for a fresh starting location.
   /// For the initial update, only locations with a timestamp within 5 seconds are accepted.
   /// Additionally, during the first 10 seconds of the workout, any update that is more than 750 meters
   /// away from the accepted initial location is ignored.
   public func locationManager(_ manager: CLLocationManager, didUpdateLocations newLocs: [CLLocation]) {
	  // Keep existing guards
	  guard workoutState == .running, weIsRecording else {
		 return
	  }

	  // Check for driving speed
	  if let latestLocation = newLocs.last {
		 // Convert speed from m/s to mph
		 let speedInMph = (latestLocation.speed * 2.23694)

		 if speedInMph > maxSpeedMph {
			consecutiveHighSpeedPoints += 1

			if consecutiveHighSpeedPoints >= maxHighSpeedConsecutive && !isShowingDrivingAlert {
			   isShowingDrivingAlert = true
			   session?.pause()
			   shouldInsertRouteData = false
			   presentDrivingAlert()
			   return
			}
		 } else {
			consecutiveHighSpeedPoints = 0
		 }
	  }

	  // Proceed with normal location updates if not driving
	  if shouldInsertRouteData {
		 // Keep existing mile trigger logic
		 let prevMiles = Int(distance)
		 locationsArray.append(contentsOf: newLocs)
		 distance = locationsArray.calculatedDistance / metersToMiles
		 let currentMiles = Int(distance)

		 if currentMiles > prevMiles {
			lastHapticMile = currentMiles
			WKInterfaceDevice.current().play(.notification)
			print("[UWM] Mile alert immediately triggered at exact mile: \(currentMiles)")
		 }

		 if let lastLocation = newLocs.last {
			NotificationCenter.default.post(name: .didUpdateLocation, object: lastLocation)
		 }
	  }
   }

   // MARK: - Automatic Workout Detection Methods (UPDATED)

   public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
	  print("Location manager error: \(error.localizedDescription)")
   }

   public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
	  switch status {
		 case .authorizedAlways, .authorizedWhenInUse:
			return
		 case .notDetermined, .denied, .restricted:
			manager.requestWhenInUseAuthorization()
		 @unknown default:
			fatalError("Unhandled authorization status.")
	  }
   }

   // MARK: - Driving Alert

   /// Presents an alert if high speeds are detected, to check whether the user is driving.
   func presentDrivingAlert() {
	  guard let ctrl = WKExtension.shared().rootInterfaceController else {
		 session?.resume()
		 isShowingDrivingAlert = false
		 return
	  }

	  WKInterfaceDevice.current().play(.directionDown)

	  savedHapticState = isBeep
	  isBeep = false
	  isTimerPaused = true
	  timer?.invalidate()
	  timer = nil

	  let endAction = WKAlertAction(title: "End Workout", style: .destructive) { [weak self] in
		 guard let self = self else { return }
		 self.stopAndFinish()
		 self.isShowingDrivingAlert = false
		 self.isBeep = self.savedHapticState
		 self.isTimerPaused = false
	  }

	  let ignoreAction = WKAlertAction(title: "Ignore", style: .default) { [weak self] in
		 guard let self = self else { return }
		 self.session?.resume()
		 self.consecutiveHighSpeedPoints = 0
		 self.isShowingDrivingAlert = false
		 self.isBeep = self.savedHapticState
		 self.shouldInsertRouteData = true
		 self.isTimerPaused = false
		 self.startTimer()
	  }

	  ctrl.presentAlert(
		 withTitle: "Are You Driving?",
		 message: "Speed over \(Int(maxSpeedMph)) mph.\nEnd the workout?",
		 preferredStyle: .actionSheet,
		 actions: [endAction, ignoreAction]
	  )
   }

   // MARK: - HealthKit Workout Session Delegate

   /// Requests authorization to read and write HealthKit data.
   func requestHKAuth() {
	  let toWrite: Set<HKSampleType> = [
		 HKObjectType.workoutType(),
		 HKSeriesType.workoutRoute()
	  ]
	  let toRead: Set<HKObjectType> = [
		 HKObjectType.workoutType(),
		 HKSeriesType.workoutRoute(),
		 HKObjectType.quantityType(forIdentifier: .heartRate)!,
		 HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
		 HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
	  ]
	  healthStore.requestAuthorization(toShare: toWrite, read: toRead) { success, err in
		 if let e = err {
			print("HealthKit auth error: \(e.localizedDescription)")
		 } else {
			print("HealthKit auth success: \(success)")
		 }
	  }
   }

   /// Delegate method that tracks state changes in the workout session.
   ///
   /// Modification: When the session state transitions to .ended or .stopped, if the
   /// flag `shouldFinishWorkoutAfterSessionEnd` is set, we finalize the workout.
   // FIX: Improve the session state change handler to better handle workout finishing
   public func workoutSession(_ workoutSession: HKWorkoutSession,
							  didChangeTo toState: HKWorkoutSessionState,
							  from fromState: HKWorkoutSessionState,
							  date: Date) {
	  print("[UWM] Session changed from \(fromState.rawValue) to \(toState.rawValue)")

	  DispatchQueue.main.async {
		 switch toState {
			case .running:
			   self.weIsRecording = true
			   self.workoutState = .running
			case .paused, .prepared:
			   self.weIsRecording = false
			   self.workoutState = .paused
			case .ended, .stopped:
			   self.weIsRecording = false
			   self.workoutState = .ended

			   // If we intended to finish the workout, do so now after session end
			   if self.shouldFinishWorkoutAfterSessionEnd {
				  print("[UWM] Session ended - proceeding with finishWorkoutAndRoute")
				  self.finishWorkoutAndRoute()
				  self.shouldFinishWorkoutAfterSessionEnd = false
			   }
			case .notStarted:
			   self.weIsRecording = false
			   self.workoutState = .notStarted
			@unknown default:
			   self.weIsRecording = false
			   self.workoutState = .notStarted
		 }
	  }
   }

   /// Pauses the workout session.
   func pauseWorkout() {
	  session?.pause()
   }

   /// Resumes the workout session.
   func resumeWorkout() {
	  session?.resume()
   }

   public func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
	  print("Workout session error: \(error.localizedDescription)")
   }

   public func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
	  // no-op
   }

   public func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
							  didCollectDataOf collectedTypes: Set<HKSampleType>) {
	  for type in collectedTypes {
		 guard let quantityType = type as? HKQuantityType else { continue }
		 let stats = workoutBuilder.statistics(for: quantityType)
		 updateForStatistics(stats)
	  }
   }

   public func updateForStatistics(_ statistics: HKStatistics?) {
	  guard let s = statistics else { return }
	  DispatchQueue.main.async {
		 if s.quantityType == HKQuantityType.quantityType(forIdentifier: .heartRate) {
			let hrUnit = HKUnit.count().unitDivided(by: .minute())
			self.heartRate = s.mostRecentQuantity()?.doubleValue(for: hrUnit) ?? 0
		 } else if s.quantityType == HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
			// Add this else if block for energy burned
			let energyUnit = HKUnit.kilocalorie()
			self.energyBurned = s.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
		 }
	  }
   }

   // MARK: - Timer

   func numTimerHours() -> Int {
	  Int(elapsedTime / 3600)
   }

   /// Formats the elapsed time into a string.
   private func formatElapsed(_ interval: TimeInterval) -> String {
	  let i = Int(interval)
	  let secs = i % 60
	  let mins = (i / 60) % 60
	  let hrs  = (i / 3600)
	  if hrs > 0 {
		 return String(format: "%02d:%02d:%02d", hrs, mins, secs)
	  } else {
		 return String(format: "%02d:%02d", mins, secs)
	  }
   }

   /// Starts the timer that updates elapsed time.
   private func startTimer() {
	  timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
		 guard let self = self,
			   self.weIsRecording,
			   !self.isTimerPaused else { return }
		 self.elapsedTime += 1
		 self.formattedTimeString = self.formatElapsed(self.elapsedTime)
	  }
   }

   func forceLocationRefresh() {
	  LMDelegate.stopUpdatingLocation()
	  // Wait briefly before restarting
	  DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
		 self?.LMDelegate.startUpdatingLocation()
	  }
   }

   // MARK: - Automatic Workout Detection Methods

   func startMonitoringActivity() {
	  guard CMMotionActivityManager.isActivityAvailable() else {
		 print("[UWM] 🚨 Motion activity NOT available!")
		 isWalkingTriggerOn = false
		 return
	  }

	  activityManager.startActivityUpdates(to: .main) { [weak self] activity in
		 guard let self = self, let activity = activity else { return }

		 print("[UWM] ⚠️ Explicit Activity Detected: walking=\(activity.walking), running=\(activity.running), stationary=\(activity.stationary)")

		 if activity.stationary {
			if self.userDeclinedCurrentActivity {
			   self.userDeclinedCurrentActivity = false
			   print("[UWM] ✅ User inactivity explicitly detected. Resetting declined activity flag.")
			}
			return
		 }

		 if (activity.walking || activity.running), self.workoutState == .notStarted {
			print("[UWM] ✅ handlePotentialWorkoutStart explicitly called!")
			self.handlePotentialWorkoutStart()
		 }
	  }

	  isWalkingTriggerOn = true
   }

   private func handlePotentialWorkoutStart() {
	  guard !userDeclinedCurrentActivity else {
		 print("[UWM] ⚠️ Explicitly NOT prompting again. User previously declined this activity.")
		 return
	  }

	  startBufferingLocations()

	  DispatchQueue.main.asyncAfter(deadline: .now() + activityDetectionThreshold) { [weak self] in
		 guard let self = self, self.workoutState == .notStarted, !self.userDeclinedCurrentActivity else { return }
		 self.promptUserToStartWorkout()
	  }

	  bufferingTimer = Timer.scheduledTimer(withTimeInterval: maxBufferingTime, repeats: false) { [weak self] _ in
		 self?.clearBufferedLocations()
	  }
   }

   private func handlePotentialWorkoutStartFirstTime() {
	  guard bufferedLocations.isEmpty else { return }

	  startBufferingLocations()

	  DispatchQueue.main.asyncAfter(deadline: .now() + activityDetectionThreshold) { [weak self] in
		 guard let self = self, self.workoutState == .notStarted else { return }
		 self.promptUserToStartWorkout()
	  }

	  bufferingTimer = Timer.scheduledTimer(withTimeInterval: maxBufferingTime, repeats: false) { [weak self] _ in
		 self?.clearBufferedLocations()
	  }
   }

   private func startBufferingLocations() {
	  LMDelegate.startUpdatingLocation()
	  NotificationCenter.default.addObserver(self, selector: #selector(bufferLocation(_:)), name: .didUpdateLocation, object: nil)
   }

   @objc private func bufferLocation(_ notification: Notification) {
	  guard let location = notification.object as? CLLocation else { return }
	  bufferedLocations.append(location)
	  print("[UWM] 📍 Buffered Location Explicitly: \(location.coordinate.latitude), \(location.coordinate.longitude), accuracy=\(location.horizontalAccuracy)m")
   }

   private func promptUserToStartWorkout() {
	  let content = UNMutableNotificationContent()
	  content.title = "Workout detected!"
	  content.body = "Are you walking now?"
	  content.categoryIdentifier = "WORKOUT_DETECTED"
	  content.sound = .default

	  let request = UNNotificationRequest(
		 identifier: UUID().uuidString,
		 content: content,
		 trigger: nil
	  )

	  UNUserNotificationCenter.current().add(request) { error in
		 if let error = error {
			print("[UWM] ❌ Explicit notification scheduling FAILED: \(error.localizedDescription)")
		 } else {
			print("[UWM] ✅ Explicit notification scheduled successfully!")
		 }
	  }

	  promptDismissTimer = Timer.scheduledTimer(withTimeInterval: alertAutoDismissTime, repeats: false) { [weak self] _ in
		 self?.clearBufferedLocations()
		 UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [request.identifier])
	  }
   }

   func userConfirmedWorkout() {
	  startNewWorkout()

	  guard !bufferedLocations.isEmpty else {
		 print("[UWM] ❌ No buffered locations explicitly available at confirmation!")
		 return
	  }

	  guard let routeBuilder = routeBuilder else {
		 print("[UWM] ❌ routeBuilder is explicitly nil!")
		 return
	  }

	  routeBuilder.insertRouteData(bufferedLocations) { success, error in
		 if success {
			print("[UWM] ✅ Buffered locations explicitly inserted into workout route.")
		 } else if let error = error {
			print("[UWM] ❌ Failed explicitly to insert buffered locations: \(error.localizedDescription)")
		 }
	  }

	  // Explicitly calculate distance immediately for UI
	  locationsArray.append(contentsOf: bufferedLocations)
	  distance = locationsArray.calculatedDistance / metersToMiles
	  print("[UWM] ✅ Explicitly updated distance from buffered locations: \(distance) miles.")

	  clearBufferedLocations()
   }

   func userDeclinedWorkout() {
	  clearBufferedLocations()
	  userDeclinedCurrentActivity = true
	  print("[UWM] ✅ User explicitly declined workout. Temporarily disabling further alerts for this session.")
   }

   private func clearBufferedLocations() {
	  bufferedLocations.removeAll()
	  bufferingTimer?.invalidate()
	  promptDismissTimer?.invalidate()
	  NotificationCenter.default.removeObserver(self, name: .didUpdateLocation, object: nil)
	  LMDelegate.stopUpdatingLocation()

	  isWalkingTriggerOn = false
   }

   /// Toggles the walking trigger and handles buffered locations.
   /// - Parameter isOn: A Boolean indicating whether the walking trigger is enabled.
   func toggleWalkingTrigger(_ isOn: Bool) {
	  isWalkingTriggerOn = isOn
	  if !isOn {
		 clearBufferedLocations()
		 activityManager.stopActivityUpdates()
		 print("[UWM] 🚫 Walking trigger explicitly turned OFF. Buffered locations cleared.")
	  } else {
		 startMonitoringActivity()
		 print("[UWM] ✅ Walking trigger explicitly turned ON.")
	  }
   }

   // MARK: - Helper method to completely stop location updates
   private func stopAllLocationUpdates() {
	  LMDelegate.delegate = nil  // Remove self as delegate
	  LMDelegate.stopUpdatingLocation()
	  LMDelegate.stopUpdatingHeading()
   }

   // MARK: End of Class
}

extension Notification.Name {
   static let didUpdateLocation = Notification.Name("didUpdateLocation")
}

/// A simple data model for altitude data points.
struct AltitudeDataPoint: Identifiable {
   let id = UUID()
   let value: Double
   let dist: Double
}

extension Array where Element: CLLocation {
   /// Calculates the total distance by summing each distance between consecutive locations.
   var calculatedDistance: CLLocationDistance {
	  guard count > 1 else { return 0 }
	  return zip(self, dropFirst()).reduce(0) { distance, pair in
		 distance + pair.0.distance(from: pair.1)
	  }
   }
}
