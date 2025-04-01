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

		 ScrollView(.vertical) {
			VStack(spacing: 20) {
			   // MOVE: Weather info to top
			   if let weatherSymbol = metricMeta.weatherSymbol {
				  VStack(alignment: .leading, spacing: 12) {
					 Text("Weather Summary")
						.font(.system(size: 20, weight: .semibold))
						.foregroundColor(.white)

					 HStack(spacing: 15) {
						VStack(alignment: .leading) {
						   if let temp = metricMeta.weatherTemp {
							  Text("\(temp)°F")
								 .font(.system(size: 24, weight: .bold))
								 .foregroundColor(.white)
						   }

						   Text(metricMeta.cityName)
							  .font(.system(size: 16))
							  .foregroundColor(.white.opacity(0.8))
						}

						Spacer()

						Image(systemName: weatherSymbol)
						   .font(.system(size: 32))
						   .foregroundColor(.white)
					 }
				  }
				  .padding()
				  .background(
					 WeatherGradient(from: weatherSymbol).gradient
				  )
				  .cornerRadius(15)
				  .padding(.horizontal)
			   }

			   // CHANGE: Use LazyVGrid for metrics
			   let columns = [
				  GridItem(.flexible(), spacing: 16),
				  GridItem(.flexible(), spacing: 16)
			   ]

			   LazyVGrid(columns: columns, spacing: 16) {
				  // 1. Start Time
				  MetricBox(
					 title: "Start",
					 value: metricMeta.startDate.formatted(date: .abbreviated, time: .shortened),
					 textSize: textSizeBig
				  )

				  // 2. End Time
				  MetricBox(
					 title: "End",
					 value: endTime.formatted(date: .abbreviated, time: .shortened),
					 textSize: textSizeBig
				  )

				  // 3. Distance
				  MetricBox(
					 title: "Distance",
					 value: String(format: "%.2f", workout.distance),
					 textSize: textSizeBig
				  )

				  // 4. Total Time
				  MetricBox(
					 title: "Total Time",
					 value: metricMeta.totalTime,
					 textSize: textSizeBig
				  )

				  // 5. Average Pace
				  MetricBox(
					 title: "Avg Pace",
					 value: averagePace,
					 textSize: textSizeBig
				  )

				  // 6. Average Speed
				  if let avgSpeed = metricMeta.averageSpeed {
					 MetricBox(
						title: "Avg Speed",
						value: String(format: "%.1f", avgSpeed),
						textSize: textSizeBig
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

struct MetricBox: View {
   let title: String
   let value: String
   let textSize: Int

   var body: some View {
	  VStack(alignment: .leading, spacing: 4) {
		 Text(title)
			.font(.system(size: CGFloat(textSize - 15)))
			.foregroundColor(.white)
			.opacity(0.7)

		 HStack {
			Text(value)
			   .font(.system(size: CGFloat(textSize)).weight(.light))
			   .foregroundColor(.white)
			   .opacity(0.65)
			   .minimumScaleFactor(0.3)
			   .lineLimit(1)

			Spacer()
		 }
		 .padding(12)
		 .frame(maxWidth: .infinity)
		 .background(Color.white.opacity(0.15))
		 .cornerRadius(15)
	  }
   }
}

private extension Color {
   static let systemBackground = Color(UIColor.systemBackground)
}
