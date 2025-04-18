import SwiftUI
import HealthKit

public struct MetricsView: View {
   var workout: WorkoutCore
   var metricMeta: MetricMeta

   private var textSizeBig: Int = 30
   private var textSizeSmall: Int = 20

   private var averagePace: String {
	  guard workout.distance > 0 else { return "0:00" }

	  let components = metricMeta.totalTime.split(separator: ":")
	  var totalSeconds = 0

	  if components.count == 2 {
		 if let minutes = Int(components[0]),
			let seconds = Int(components[1]) {
			totalSeconds = minutes * 60 + seconds
		 }
	  } else if components.count == 3 {
		 if let hours = Int(components[0]),
			let minutes = Int(components[1]),
			let seconds = Int(components[2]) {
			totalSeconds = hours * 3600 + minutes * 60 + seconds
		 }
	  }

	  let paceInMinutes = Double(totalSeconds) / 60.0 / workout.distance
	  let minutes = Int(paceInMinutes)
	  let seconds = Int((paceInMinutes - Double(minutes)) * 60)

	  return String(format: "%d:%02d", minutes, seconds)
   }

   private var endTime: Date {
	  let components = metricMeta.totalTime.split(separator: ":")
	  var secondsToAdd = 0

	  if components.count == 2 {
		 if let minutes = Int(components[0]),
			let seconds = Int(components[1]) {
			secondsToAdd = minutes * 60 + seconds
		 }
	  } else if components.count == 3 {
		 if let hours = Int(components[0]),
			let minutes = Int(components[1]),
			let seconds = Int(components[2]) {
			secondsToAdd = hours * 3600 + minutes * 60 + seconds
		 }
	  }

	  return metricMeta.startDate.addingTimeInterval(TimeInterval(secondsToAdd))
   }

   private var formattedHeartRate: String {
	  if let heartRate = metricMeta.averageHeartRate {
		 return String(format: "%.0f bpm", heartRate)
	  }
	  return "-- bpm"
   }

   private var formattedElevationGain: String {
	  if let elevation = metricMeta.elevationGain {
		 return String(format: "%.0f ft", elevation)
	  }
	  return "-- ft"
   }

   private var formattedAverageSpeed: String {
	  if let speed = metricMeta.averageSpeed {
		 return String(format: "%.1f mph", speed)
	  }
	  return "-- mph"
   }

   private var formattedCadence: String {
	  if let cadence = metricMeta.cadence {
		 return String(format: "%.0f spm", cadence)
	  }
	  return "-- spm"
   }

   private var formattedGroundContact: String {
	  if let groundContact = metricMeta.groundContactTime {
		 return String(format: "%.0f ms", groundContact)
	  }
	  return "-- ms"
   }

   private var formattedVerticalOscillation: String {
	  if let oscillation = metricMeta.verticalOscillation {
		 return String(format: "%.1f cm", oscillation)
	  }
	  return "-- cm"
   }

   private var formattedStrideLength: String {
	  if let strideLength = metricMeta.strideLength {
		 return String(format: "%.2f m", strideLength)
	  }
	  return "-- m"
   }

   private var formattedHeartRateRange: String {
	  if let min = metricMeta.minHeartRate, let max = metricMeta.maxHeartRate {
		 return String(format: "%.0f-%.0f bpm", min, max)
	  }
	  return "-- bpm"
   }

   private var formattedElevationChange: String {
	  if let gain = metricMeta.elevationGain, let loss = metricMeta.elevationLoss {
		 return String(format: "+%.0f/-%.0f ft", gain, loss)
	  }
	  return "-- ft"
   }

   public init(workout: WorkoutCore, metricMeta: MetricMeta) {
	  self.workout = workout
	  self.metricMeta = metricMeta
   }

   public var body: some View {
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

		 ScrollView {
			VStack(spacing: 20) {
			   // Weather Summary Section with Weather Background
			   VStack {
				  Text("Weather Summary")
					 .font(.title2)
					 .fontWeight(.bold)
					 .foregroundColor(.white)

				  HStack {
					 Text("\(metricMeta.weatherTemp ?? "N/A")°F")
						.font(.system(size: 48, weight: .bold))
					 Spacer()
					 Image(systemName: metricMeta.weatherSymbol ?? "sun.max.fill")
						.font(.system(size: 40))
				  }
				  .foregroundColor(.white)

				  Text(metricMeta.cityName)
					 .font(.title3)
					 .foregroundColor(.white)
			   }
			   .padding()
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
			   .clipShape(RoundedRectangle(cornerRadius: 15))
			   .padding(.horizontal)

			   // CHANGE: Use LazyVGrid for metrics
			   let columns = [
				  GridItem(.flexible(), spacing: 16),
				  GridItem(.flexible(), spacing: 16)
			   ]

			   LazyVGrid(columns: columns, spacing: 16) {
				  // Core Metrics Section
				  Group {
					 MetricBox(
						title: "Start",
						value: metricMeta.startDate.formatted(date: .abbreviated, time: .shortened),
						textSize: textSizeBig,
						iconName: "clock.arrow.circlepath"
					 )

					 MetricBox(
						title: "End",
						value: endTime.formatted(date: .abbreviated, time: .shortened),
						textSize: textSizeBig,
						iconName: "clock.arrow.2.circlepath"
					 )

					 MetricBox(
						title: "Distance",
						value: String(format: "%.2f", workout.distance),
						textSize: textSizeBig,
						iconName: "ruler"
					 )

					 MetricBox(
						title: "Duration",
						value: metricMeta.totalTime,
						textSize: textSizeBig,
						iconName: "stopwatch"
					 )
				  }

				  // Pace & Speed Section
				  Group {
					 MetricBox(
						title: "Avg Pace",
						value: averagePace,
						textSize: textSizeBig,
						iconName: "speedometer"
					 )

					 if let speed = metricMeta.averageSpeed {
						MetricBox(
						   title: "Avg Speed",
						   value: String(format: "%.1f mph", speed),
						   textSize: textSizeBig,
						   iconName: "gauge.medium"
						)
					 }
				  }

				  // Heart Rate Section
				  Group {
					 MetricBox(
						title: "Heart Rate",
						value: formattedHeartRate,
						textSize: textSizeBig,
						iconName: "heart.fill"
					 )

					 MetricBox(
						title: "HR Range",
						value: formattedHeartRateRange,
						textSize: textSizeBig,
						iconName: "waveform.path.ecg"
					 )
				  }

				  // Energy & Steps Section
				  Group {
					 if let steps = metricMeta.stepCount {
						MetricBox(
						   title: "Steps",
						   value: String(format: "%d", steps),
						   textSize: textSizeBig,
						   iconName: "figure.walk"
						)
					 }

					 if let energy = metricMeta.energyBurned {
						MetricBox(
						   title: "Energy",
						   value: String(format: "%.0f cal", energy),
						   textSize: textSizeBig,
						   iconName: "flame.fill"
						)
					 }
				  }

				  // Running Dynamics Section
				  Group {
					 MetricBox(
						title: "Cadence",
						value: formattedCadence,
						textSize: textSizeBig,
						iconName: "figure.walk.motion"
					 )

					 MetricBox(
						title: "Ground Contact",
						value: formattedGroundContact,
						textSize: textSizeBig,
						iconName: "figure.walk.arrival"
					 )
				  }

				  // Elevation Section
				  Group {
					 MetricBox(
						title: "Elevation",
						value: formattedElevationChange,
						textSize: textSizeBig,
						iconName: "mountain.2.fill"
					 )

					 if let currentElevation = metricMeta.currentElevation {
						MetricBox(
						   title: "Current Alt",
						   value: String(format: "%.0f ft", currentElevation),
						   textSize: textSizeBig,
						   iconName: "arrow.up.right.circle"
						)
					 }
				  }

				  // Advanced Running Metrics
				  Group {
					 MetricBox(
						title: "Stride Length",
						value: formattedStrideLength,
						textSize: textSizeBig,
						iconName: "figure.walk.circle"
					 )

					 MetricBox(
						title: "Vertical OSC",
						value: formattedVerticalOscillation,
						textSize: textSizeBig,
						iconName: "arrow.up.and.down"
					 )
				  }
			   }
			   .padding(.horizontal)
			}
			.padding(.vertical)
		 }
	  }
	  .navigationTitle("Workout Details")
	  .navigationBarTitleDisplayMode(.inline)
   }
}

private extension Color {
   static let systemBackground = Color(UIColor.systemBackground)
}
