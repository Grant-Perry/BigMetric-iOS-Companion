import SwiftUI
import MapKit
import HealthKit

struct FullMapView: View {
   let workout: HKWorkout
   @ObservedObject var polyViewModel: PolyViewModel

   @State private var routeCoordinates: [CLLocationCoordinate2D] = []
   @State private var metricMeta: MetricMeta? = nil
   @State private var convertedWorkout: WorkoutCore? = nil
   @State private var isError: Bool = false
   @State private var errorMessage: String = ""
   @State private var isLoading: Bool = false
   @State private var mapType: MKMapType = .standard

   var body: some View {
	  VStack {
		 Picker("Map Type", selection: $mapType) {
			Text("Standard").tag(MKMapType.standard)
			Text("Satellite").tag(MKMapType.satellite)
		 }
		 .pickerStyle(SegmentedPickerStyle())
		 .padding()

		 if isLoading {
			ProgressView()
			   .frame(maxWidth: .infinity, alignment: .center)
		 } else if isError {
			Text(errorMessage)
			   .font(.system(size: 17))
			   .foregroundColor(.red)
			   .frame(maxWidth: .infinity, alignment: .center)
		 } else {
			if !routeCoordinates.isEmpty {
			   GradientMapView(coordinates: routeCoordinates, mapType: $mapType)
			} else {
			   Text("No route data available.")
				  .foregroundColor(.gray)
			}
		 }
	  }
	  .safeAreaInset(edge: .top) {
		 if let metricMeta = metricMeta, let workoutCore = convertedWorkout {
			VStack {
			   WorkoutMetricsView(
				  workout: workoutCore,
				  metricMeta: metricMeta,
				  polyViewModel: polyViewModel
			   )
			}
			.background(
			   ZStack {
				  Image(metricMeta.weatherSymbol != nil ?
						WeatherGradient(from: metricMeta.weatherSymbol).backgroundImage :
						   WeatherGradient.default.backgroundImage)
				  .resizable()
				  .aspectRatio(contentMode: .fill)
				  .opacity(0.95)
				  Color.black.opacity(0.15)
			   }
			)
			.clipShape(RoundedRectangle(cornerRadius: 24))
			.shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
			.padding(.horizontal, 12)
		 }
	  }
	  .navigationTitle("Workout Map")
	  .navigationBarTitleDisplayMode(.inline)
	  .task {
		 await loadWorkoutData()
	  }
   }

   private func loadWorkoutData() async {
	  do {
		 isLoading = true
		 WorkoutCore.shared.update(from: workout)
		 convertedWorkout = WorkoutCore.shared

		 if let fetchedRoute = await polyViewModel.fetchDetailedRouteData(for: workout) {
			routeCoordinates = fetchedRoute
		 } else {
			throw NSError(domain: "com.BigPoly", code: 404, userInfo: [NSLocalizedDescriptionKey: "No route data found."])
		 }

		 let cityName = await polyViewModel.fetchCityName(for: workout) ?? "Unknown City"
		 let totalTime = formatDuration(polyViewModel.fetchDuration(for: workout))
		 let averageSpeed = polyViewModel.fetchAverageSpeed(for: workout)

		 var weatherTemp: String? = nil
		 var weatherSymbol: String? = nil
		 if let (temp, symbol) = await polyViewModel.fetchWeather(for: workout) {
			weatherTemp = temp
			weatherSymbol = symbol
		 }

		 let stepCount = workout.metadata?["stepCount"].flatMap {
			if let stepString = $0 as? String, let steps = Int(stepString) {
			   let formatter = NumberFormatter()
			   formatter.numberStyle = .decimal
			   return formatter.string(from: NSNumber(value: steps)).map { Int($0.filter { $0.isNumber })} ?? steps
			}
			return nil
		 }

		 let energyBurned: Double?
		 if #available(iOS 18.0, *) {
			energyBurned = workout.statistics(for: HKQuantityType(.activeEnergyBurned))?
			   .sumQuantity()?.doubleValue(for: .kilocalorie())
		 } else {
			energyBurned = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie())
		 }

		 var metricMeta = MetricMeta(
			weatherTemp: weatherTemp,
			weatherSymbol: weatherSymbol,
			cityName: cityName,
			totalTime: totalTime,
			startDate: workout.startDate
		 )

		 metricMeta.averageSpeed = averageSpeed
		 metricMeta.stepCount = stepCount
		 metricMeta.energyBurned = energyBurned

		 self.metricMeta = metricMeta
		 isLoading = false
	  } catch {
		 isError = true
		 errorMessage = error.localizedDescription
		 print("Error fetching data: \(error.localizedDescription)")
		 isLoading = false
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
}
