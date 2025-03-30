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

				  // Steps
				  SummaryMetricView(
					 title: "Steps",
					 value: "\(unifiedWorkoutManager.workoutStepCount)",
					 textSize: textSizeBig
				  )
				  .padding(.vertical, 8)
				  .frame(maxWidth: .infinity)
				  .background(Color.white.opacity(0.15))
				  .cornerRadius(15)
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
			   .background(Color.white.opacity(0.15))
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
