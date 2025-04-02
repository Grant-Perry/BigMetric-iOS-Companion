import SwiftUI
import HealthKit

struct summary: View {
   var unifiedWorkoutManager: UnifiedWorkoutManager
   var weatherKitManager: WeatherKitManager

   @Binding var selectedTab: Int

   var textSizeBig: Int = 30
   var textSizeSmall: Int = 20

   private var appVersion: String {
	  return "\(AppConstants.appName) - ver: \(AppConstants.getVersion())"
   }

   private var averagePace: String {
	  let timeInMinutes = unifiedWorkoutManager.elapsedTime / 60
	  let distanceInMiles = unifiedWorkoutManager.distance

	  guard distanceInMiles > 0 else { return "0:00" }

	  let paceInMinutesPerMile = timeInMinutes / distanceInMiles
	  let minutes = Int(paceInMinutesPerMile)
	  let seconds = Int((paceInMinutesPerMile - Double(minutes)) * 60)

	  return String(format: "%d:%02d", minutes, seconds)
   }

   var body: some View {
	  ZStack {
		 LinearGradient(
			gradient: Gradient(
			   colors: [
				  .purple.opacity(0.8),
				  .blue.opacity(0.6),
				  .purple.opacity(0.3)
			   ]
			),
			startPoint: .topLeading,
			endPoint: .bottomTrailing
		 )
		 .ignoresSafeArea()

		 ScrollView(.vertical) {
			VStack(spacing: 20) {
			   // Main metrics card
			   VStack(spacing: 16) {
				  // Distance
				  SummaryMetricView(
					 title: "Distance",
					 value: formatDistance(unifiedWorkoutManager.distance),
					 textSize: textSizeBig
				  )
				  .padding(.vertical, 8)
				  .frame(maxWidth: .infinity)
				  .background(Color.white.opacity(0.15))
				  .cornerRadius(15)

				  // Time
				  SummaryMetricView(
					 title: "Total Time",
					 value: unifiedWorkoutManager.formattedTimeString,
					 textSize: textSizeBig
				  )
				  .padding(.vertical, 8)
				  .frame(maxWidth: .infinity)
				  .background(Color.white.opacity(0.15))
				  .cornerRadius(15)

				  // Average Pace
				  SummaryMetricView(
					 title: "Avg Pace (min/mi)",
					 value: averagePace,
					 textSize: textSizeBig
				  )
				  .padding(.vertical, 8)
				  .frame(maxWidth: .infinity)
				  .background(Color.white.opacity(0.15))
				  .cornerRadius(15)

				  // Steps
				  HStack(spacing: 0) {
					 Text("Steps")
						.font(.system(size: CGFloat(textSizeSmall)))
						.foregroundColor(.white)
						.opacity(0.7)
						.padding(.leading)

					 Spacer()

					 Text("\(unifiedWorkoutManager.workoutStepCount)")
						.font(.system(size: 65).weight(.light))
						.foregroundColor(.white)
						.opacity(0.65)
						.minimumScaleFactor(0.3)
						.lineLimit(1)
						.padding(.horizontal)
				  }
				  .padding(.vertical, 8)
				  .frame(maxWidth: .infinity)
				  .background(Color.white.opacity(0.15))
				  .cornerRadius(15)

				  // Weather card
			   }
			   .padding(.horizontal)

			   // Weather card
			   VStack(alignment: .leading, spacing: 12) {
				  if !weatherKitManager.tempVar.isEmpty {
					 Text("Weather Summary")
						.font(.system(size: 20, weight: .semibold))
						.foregroundColor(.white)

					 // Temperature row
					 HStack(spacing: 12) {
						VStack(alignment: .leading) {
						   Text(weatherKitManager.tempVar + "°F")
							  .font(.system(size: 24, weight: .bold))
							  .foregroundColor(.white)
						   Text("High: \(weatherKitManager.highTempVar)° / Low: \(weatherKitManager.lowTempVar)°")
							  .font(.system(size: 14))
							  .foregroundColor(.white.opacity(0.8))
						}
						Spacer()
						Image(systemName: weatherKitManager.symbolVar)
						   .font(.system(size: 32))
						   .foregroundColor(.white)
					 }

					 // Wind info
					 HStack {
						Image(systemName: "wind")
						Text("\(String(format: "%.0f", weatherKitManager.windSpeedVar)) mph \(weatherKitManager.windDirectionVar)")
					 }
					 .font(.system(size: 16))
					 .foregroundColor(.white.opacity(0.9))

					 if !weatherKitManager.weekForecast.isEmpty {
						Text("\(weatherKitManager.weekForecast.count)-Day Forecast Available")
						   .font(.system(size: 14))
						   .foregroundColor(.white.opacity(0.7))
					 }
				  } else {
					 Text("Weather data unavailable")
						.font(.system(size: 16))
						.foregroundColor(.white.opacity(0.6))
				  }
			   }
			   .padding()
			   .background(
				  WeatherGradient(from: weatherKitManager.symbolVar).gradient
			   )
			   .cornerRadius(15)
			   .padding(.horizontal)

			   // Version info
			   Text(appVersion)
				  .font(.system(size: 14))
				  .foregroundColor(.white.opacity(0.7))

			   // Done button with modern styling
			   if unifiedWorkoutManager.workoutState == .ended || unifiedWorkoutManager.workoutFullySaved {
				  Button(action: {
					 unifiedWorkoutManager.resetForNewWorkout()
					 selectedTab = 2
					 unifiedWorkoutManager.workoutFullySaved = false
				  }) {
					 HStack {
						Image(systemName: "checkmark.circle.fill")
						Text("Finish")
					 }
					 .font(.system(size: 18, weight: .semibold))
					 .foregroundColor(.white)
					 .frame(maxWidth: .infinity)
					 .padding(.vertical, 12)
					 .background(
						LinearGradient(
						   gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
						   startPoint: .leading,
						   endPoint: .trailing
						)
					 )
					 .cornerRadius(20)
				  }
				  .padding(.horizontal)
			   } else {
				  HStack {
					 ProgressView()
						.progressViewStyle(CircularProgressViewStyle(tint: .white))
					 Text("Saving workout data...")
						.font(.system(size: 14))
						.foregroundColor(.white.opacity(0.7))
				  }
				  .padding(.top, 8)
			   }
			}
			.padding(.vertical)
		 }
	  }
	  .navigationTitle("Summary")
	  .navigationBarTitleDisplayMode(.inline)
	  .onAppear {
		 if let lastLoc = unifiedWorkoutManager.lastLocation?.coordinate {
			Task {
			   await weatherKitManager.getWeather(for: lastLoc)
			}
		 }
	  }
   }

   private func formatDistance(_ d: Double) -> String {
	  String(format: "%.2f", d)
   }
}


#Preview {
   let mockWorkoutManager = UnifiedWorkoutManager()
   let mockWeatherManager = WeatherKitManager()

   // Set mock data for workout manager
   mockWorkoutManager.distance = 5.23
   mockWorkoutManager.elapsedTime = 3600 // 1 hour
   mockWorkoutManager.formattedTimeString = "01:00:00"
   mockWorkoutManager.workoutStepCount = 8547
   mockWorkoutManager.workoutState = .ended
   mockWorkoutManager.workoutFullySaved = true

   // Set mock data for weather manager
   mockWeatherManager.tempVar = "72"
   mockWeatherManager.highTempVar = "75"
   mockWeatherManager.lowTempVar = "65"
   mockWeatherManager.symbolVar = "sun.max.fill"
   mockWeatherManager.windSpeedVar = 8.5
   mockWeatherManager.windDirectionVar = "NE"
   mockWeatherManager.weekForecast = [
	  WeatherKitManager.Forecasts(symbolName: "sun.max.fill", minTemp: "65", maxTemp: "75"),
	  WeatherKitManager.Forecasts(symbolName: "cloud.sun.fill", minTemp: "63", maxTemp: "72")
   ]

   return summary(unifiedWorkoutManager: mockWorkoutManager,
				  weatherKitManager: mockWeatherManager,
				  selectedTab: .constant(0))
   .environmentObject(mockWorkoutManager)
}
