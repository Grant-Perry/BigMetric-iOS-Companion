import SwiftUI
import HealthKit
import CoreLocation

@MainActor
class WorkoutRouteViewModel: ObservableObject {
   @Published var cityName: String = "Loading..."
   @Published var distance: Double = 0.0
   @Published var totalTime: TimeInterval = 0.0
   @Published var formattedTotalTime: String = "00:00"
   @Published var averageSpeed: Double? = nil
   @Published var weatherTemp: String? = nil
   @Published var weatherSymbol: String? = nil
   @Published var routeStartDate: Date? = nil
   @Published var isError: Bool = false
   @Published var errorMessage: String = ""
   @Published var address: Address? = nil
   @Published var isLoading = false
   @Published var appeared = false
   @Published var isDataLoaded = false
   
   private let workout: HKWorkout
   private let polyViewModel: PolyViewModel
   
   init(workout: HKWorkout, polyViewModel: PolyViewModel) {
	  self.workout = workout
	  self.polyViewModel = polyViewModel
	  
	  Task {
		 await loadWorkoutData()
	  }
   }
   
   func loadWorkoutData() async {
	  isLoading = true
	  isDataLoaded = false
	  
	  do {
		 cityName = await polyViewModel.fetchCityName(for: workout) ?? "Unknown Location"
		 distance = await polyViewModel.fetchDistance(for: workout) ?? 0
		 totalTime = polyViewModel.fetchDuration(for: workout)
		 formattedTotalTime = formatDuration(totalTime)
		 averageSpeed = polyViewModel.fetchAverageSpeed(for: workout)
		 routeStartDate = workout.startDate
		 
		 // Handle weather data and explicitly check for "xmark" symbol
		 if let (temp, symbol) = await polyViewModel.fetchWeather(for: workout),
			let unwrappedSymbol = symbol,
			unwrappedSymbol != "xmark" && !unwrappedSymbol.isEmpty {
			weatherTemp = temp
			weatherSymbol = unwrappedSymbol
		 } else {
			weatherTemp = nil
			weatherSymbol = nil
		 }
		 
		 if distance == 0 && cityName == "Unknown Location" {
			throw NSError(domain: "com.BigPoly", code: 404,
						  userInfo: [NSLocalizedDescriptionKey: "No workout data available"])
		 }
		 
		 isLoading = false
		 isDataLoaded = true
	  } catch {
		 isError = true
		 errorMessage = "Failed to load workout data. Please try again."
		 isLoading = false
		 isDataLoaded = false
	  }
   }
   
   func formatDuration(_ duration: TimeInterval) -> String {
	  let hours = Int(duration) / 3600
	  let minutes = (Int(duration) % 3600) / 60
	  let seconds = Int(duration) % 60
	  
	  if hours > 0 {
		 return String(format: "%d:%02d:%02d", hours, minutes, seconds)
	  } else {
		 return String(format: "%02d:%02d", minutes, seconds)
	  }
   }
   
   func formatPaceMinMi() -> String {
	  guard distance > 0, totalTime > 0 else { return "--" }
	  let minutes = totalTime / 60.0
	  let pace = minutes / distance
	  let wholeMinutes = Int(pace)
	  let seconds = Int((pace - Double(wholeMinutes)) * 60)
	  return String(format: "%d:%02d min/mi", wholeMinutes, seconds)
   }
}
