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
   @State private var appeared = false

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

   var body: some View {
	  ScrollView {
		 VStack(spacing: 4) {
			if isLoading {
			   LoadingState()
			} else if isError {
			   ErrorState(message: errorMessage)
			} else {
			   ContentState()
			}
		 }
		 .padding(.vertical, 2)
	  }
	  .scrollTargetBehavior(.viewAligned)
	  .task {
		 await loadWorkoutData()
	  }
   }

   // MARK: - View Components

   @ViewBuilder
   private func LoadingState() -> some View {
	  ProgressView("Loading workout data...")
		 .progressViewStyle(CircularProgressViewStyle())
		 .frame(maxWidth: .infinity, minHeight: 200)
		 .background(Color.gray.opacity(0.1))
		 .cornerRadius(16)
   }

   @ViewBuilder
   private func ErrorState(message: String) -> some View {
	  Text(message)
		 .font(.system(size: 17))
		 .foregroundColor(.red)
		 .frame(maxWidth: .infinity, minHeight: 200)
		 .background(Color.red.opacity(0.1))
		 .cornerRadius(16)
   }

   @ViewBuilder
   private func ContentState() -> some View {
	  VStack(spacing: 12) {
		 HeaderSection()
		 MetricsGrid()
			.padding(.horizontal, 16)
			.padding(.bottom, 12)
	  }
	  .background(
		 Group {
			Image(weatherSymbol != nil ?
				  WeatherGradient(from: weatherSymbol).backgroundImage :
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
	  .opacity(appeared ? 1 : 0)
	  .offset(y: appeared ? 0 : 50)
	  .animation(.spring(response: 0.6, dampingFraction: 0.8), value: appeared)
	  .onAppear { appeared = true }
   }

   @ViewBuilder
   private func HeaderSection() -> some View {
	  HStack(alignment: .top) {
		 // Left side with date and city
		 VStack(alignment: .leading, spacing: 6) {
			if let routeDate = routeStartDate {
			   Text(routeDate, formatter: dateFormatter)
				  .font(.system(size: 15))
				  .foregroundColor(.white.opacity(0.9))
				  .padding(.top, 24)
			}

			if let address = address {
			   Text(address.city)
				  .font(.system(size: 28, weight: .bold))
				  .foregroundColor(.white)
			} else {
			   Text(cityName)
				  .font(.system(size: 28, weight: .bold))
				  .foregroundColor(.white)
			}
		 }

		 Spacer()

		 // Right side with weather
		 if let wTemp = weatherTemp, let wSymbol = weatherSymbol {
			VStack(alignment: .trailing, spacing: 4) {
			   Image(systemName: wSymbol)
				  .font(.system(size: 48))
				  .symbolRenderingMode(.palette)
				  .foregroundStyle(.white)
			   Text("\(wTemp)°")
				  .font(.system(size: 32, weight: .medium))
				  .foregroundColor(.white)
			}
			.padding(.top, 24)
			.padding(.trailing, 8)
		 }
	  }
	  .frame(maxWidth: .infinity)
	  .padding(.horizontal, 16)
   }

   @ViewBuilder
   private func MetricsGrid() -> some View {
	  LazyVGrid(columns: [
		 GridItem(.flexible()),
		 GridItem(.flexible())
	  ], spacing: 12) {
		 WorkoutMetricCard(title: "Duration", value: formattedTotalTime, icon: "clock.fill", weatherSymbol: weatherSymbol)
		 WorkoutMetricCard(title: "Distance", value: String(format: "%.2f mi", distance), icon: "figure.walk", weatherSymbol: weatherSymbol)
		 WorkoutMetricCard(title: "Pace", value: formatPaceMinMi(), icon: "speedometer", weatherSymbol: weatherSymbol)

		 if let temp = weatherTemp {
			WorkoutMetricCard(title: "Temperature", value: "\(temp)°", icon: "thermometer", weatherSymbol: weatherSymbol)
		 }
	  }
   }

   // MARK: - Helper Methods

   private func loadWorkoutData() async {
	  do {
		 isLoading = true
		 cityName = await polyViewModel.fetchCityName(for: workout) ?? "Unknown Location"
		 distance = await polyViewModel.fetchDistance(for: workout) ?? 0
		 totalTime = polyViewModel.fetchDuration(for: workout)
		 formattedTotalTime = formatDuration(totalTime)
		 averageSpeed = polyViewModel.fetchAverageSpeed(for: workout)
		 routeStartDate = workout.startDate

		 if let (temp, symbol) = await polyViewModel.fetchWeather(for: workout) {
			weatherTemp = temp
			weatherSymbol = symbol
		 }

		 if distance == 0 && cityName == "Unknown Location" {
			throw NSError(domain: "com.BigPoly", code: 404,
						  userInfo: [NSLocalizedDescriptionKey: "No workout data available"])
		 }
		 isLoading = false
	  } catch {
		 isError = true
		 errorMessage = "Failed to load workout data. Please try again."
		 print("Error fetching data: \(error.localizedDescription)")
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

// MARK: - Supporting Views

struct WorkoutMetricCard: View {
   let title: String
   let value: String
   let icon: String
   let weatherSymbol: String?

   var body: some View {
	  VStack(alignment: .leading, spacing: 4) {
		 HStack {
			Image(systemName: icon)
			   .font(.system(size: 14))
			Text(title)
			   .font(.system(size: 14))
		 }
		 .foregroundColor(.white.opacity(0.9))

		 Text(value)
			.font(.system(size: 20, weight: .semibold))
			.foregroundColor(.white)
	  }
	  .frame(maxWidth: .infinity, alignment: .leading)
	  .padding(.vertical, 12)
	  .padding(.horizontal, 16)
	  .background(Color.black.opacity(0.15))
	  .cornerRadius(16)
   }
}
