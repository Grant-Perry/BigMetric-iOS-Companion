import SwiftUI
import HealthKit

struct WorkoutRouteView: View {
   let workout: HKWorkout
   @ObservedObject var polyViewModel: PolyViewModel
   @State private var metricMeta: MetricMeta? = nil

   @State private var cityName: String = "Loading..."
   @State private var distance: Double = 0.0
   @State private var totalTime: TimeInterval = 0.0
   @State private var formattedTotalTime: String = "00:00"
   @State private var averageSpeed: Double? = nil
   @State private var weatherTemp: String? = nil
   @State private var weatherSymbol: String? = nil
   @State private var routeStartDate: Date? = nil
   @State private var isError: Bool = false
   @State private var errorMessage: String = ""
   @State private var address: Address? = nil
   @State private var isLoading = false

   private var dateFormatter: DateFormatter {
	  let df = DateFormatter()
	  df.dateStyle = .medium
	  return df
   }

   private var timeFormatter: DateFormatter {
	  let df = DateFormatter()
	  df.timeStyle = .short
	  return df
   }

   private struct MetricBox: View {
	  let title: String
	  let value: String

	  var body: some View {
		 VStack(spacing: 6) {
			Text(title)
			   .font(.system(size: 15, weight: .medium))
			   .foregroundColor(.white.opacity(0.9))
			Text(value)
			   .font(.system(size: 20, weight: .bold))
			   .foregroundColor(.white)
		 }
		 .frame(maxWidth: .infinity)
	  }
   }

   var body: some View {
	  VStack(spacing: 8) {
		 if isLoading {
			ProgressView("Loading Workouts...")
			   .progressViewStyle(CircularProgressViewStyle(tint: .white))
		 } else if isError {
			Text(errorMessage)
			   .font(.system(size: 17))
			   .foregroundColor(.red)
			   .frame(maxWidth: .infinity, alignment: .center)
		 } else {
			// Main content with workout details
			VStack(spacing: 12) {
			   HStack(alignment: .top) {
				  VStack(alignment: .leading, spacing: 6) {
					 if let address = address {
						Text(address.city)
						   .font(.system(size: 28, weight: .heavy))
						   .foregroundColor(.white)
						   .shadow(radius: 2)
						   .lineLimit(1)
						   .truncationMode(.tail)
						   .frame(maxWidth: .infinity, alignment: .leading)
					 } else {
						Text(cityName)
						   .font(.system(size: 28, weight: .heavy))
						   .foregroundColor(.white)
						   .shadow(radius: 2)
						   .lineLimit(1)
						   .truncationMode(.tail)
						   .frame(maxWidth: .infinity, alignment: .leading)
						   .minimumScaleFactor(0.5)
						   .scaledToFit()
					 }

					 if let wTemp = weatherTemp, let wSymbol = weatherSymbol {
						HStack(spacing: 8) {
						   Image(systemName: wSymbol)
							  .foregroundColor(.white)
							  .font(.system(size: 16))
						   Text("\(wTemp)°")
							  .font(.system(size: 16, weight: .medium))
							  .foregroundColor(.white)
						}
						.padding(.vertical, 4)
						.padding(.horizontal, 10)
						.background(.ultraThinMaterial)
						.cornerRadius(20)
					 }
				  }

				  Spacer()

				  if let routeDate = routeStartDate {
					 VStack(alignment: .trailing, spacing: 4) {
						Text(routeDate, formatter: dateFormatter)
						   .font(.system(size: 17, weight: .medium))
						   .foregroundColor(.white)
						Text(routeDate, formatter: timeFormatter)
						   .font(.system(size: 15))
						   .foregroundColor(.white.opacity(0.9))
					 }
				  }
			   }
			   .padding(.horizontal, 16)
			   .padding(.vertical, 12)

			   if let symbol = weatherSymbol, let temp = weatherTemp {
				  HStack(alignment: .center, spacing: 0) {
					 Spacer()
					 Text("\(temp)°")
						.font(.system(size: 55))
						.offset(x: 12)
					 Image(systemName: symbol)
						.font(.system(size: 60))
						.foregroundColor(.white)
						.padding(.leading, 1)
				  }
				  .padding(.horizontal, 16)
				  .padding(.top, -35)
				  .opacity(0.8)
			   }

			   // Metrics row
			   HStack(alignment: .center, spacing: 0) {
				  MetricBox(title: "Duration", value: formattedTotalTime)
				  Divider().background(.white.opacity(0.3)).frame(width: 1, height: 40)
				  MetricBox(title: "Pace", value: formatPaceMinMi())
				  Divider().background(.white.opacity(0.3)).frame(width: 1, height: 40)
				  MetricBox(title: "Distance", value: String(format: "%.2f mi", distance))
			   }
			   .padding(.horizontal, 16)
			   .padding(.vertical, 12)
			   .background(.ultraThinMaterial)
			   .cornerRadius(12)
			}
			.background(WeatherGradient(from: weatherSymbol).gradient)
			.clipShape(RoundedRectangle(cornerRadius: 12))
		 }
	  }
	  .padding(.horizontal, 12)
	  .padding(.vertical, 8)
	  .cornerRadius(16)
	  .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
	  .task {
		 do {
			cityName = await polyViewModel.fetchCityName(for: workout) ?? "Unknown City"
			distance = await polyViewModel.fetchDistance(for: workout) ?? 0
			totalTime = polyViewModel.fetchDuration(for: workout)
			formattedTotalTime = formatDuration(totalTime)
			averageSpeed = polyViewModel.fetchAverageSpeed(for: workout)
			routeStartDate = workout.startDate

			if let (temp, symbol) = await polyViewModel.fetchWeather(for: workout) {
			   weatherTemp = temp
			   weatherSymbol = symbol
			}

			if distance == 0 && cityName == "Unknown City" {
			   throw NSError(domain: "com.BigPoly", code: 404, userInfo: [NSLocalizedDescriptionKey: "No workout data available"])
			}
		 } catch {
			isError = true
			errorMessage = "Failed to load workout data. Please try again."
			print("Error fetching data: \(error.localizedDescription)")
		 }
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
	  return String(format: "%d:%02d", wholeMinutes, seconds)
   }
}

//struct WorkoutRouteView_Previews: PreviewProvider {
//   static var previews: some View {
//	  let dummyWorkout = HKWorkout(activityType: .running,
//								   start: Date(),
//								   end: Date().addingTimeInterval(3600),
//								   duration: 3600,
//								   totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: 500),
//								   totalDistance: HKQuantity(unit: .mile(), doubleValue: 5),
//								   metadata: nil)
//
//	  WorkoutRouteView(workout: dummyWorkout, polyViewModel: PolyViewModel())
//		 .background(Color.black)
//		 .previewDisplayName("Workout Route Preview")
//   }
//}
