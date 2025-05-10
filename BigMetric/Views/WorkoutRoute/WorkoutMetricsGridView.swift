import SwiftUI

struct WorkoutMetricsGridView: View {
   let formattedTotalTime: String
   let distance: Double
   let pace: String
   let weatherTemp: String?
   let weatherSymbol: String?

   var body: some View {
	  LazyVGrid(columns: [
		 GridItem(.flexible()),
		 GridItem(.flexible())
	  ], spacing: 12) {
		 WorkoutMetricCard(title: "Duration", value: formattedTotalTime, icon: "clock", weatherSymbol: weatherSymbol)
		 WorkoutMetricCard(title: "Distance", value: String(format: "%.2f mi", distance), icon: "figure.walk", weatherSymbol: weatherSymbol)
		 WorkoutMetricCard(title: "Pace", value: pace, icon: "gauge.with.needle", weatherSymbol: weatherSymbol)

		 if let temp = weatherTemp {
			WorkoutMetricCard(title: "Temperature", value: "\(temp)°", icon: "thermometer", weatherSymbol: weatherSymbol)
		 }
	  }
   }
}

struct WorkoutMetricCard: View {
   let title: String
   let value: String
   let icon: String
   let weatherSymbol: String?

   var body: some View {
	  VStack(alignment: .leading, spacing: 6) {
		 HStack(spacing: 6) {
			Image(systemName: icon)
			   .font(.system(size: 16))
			Text(title)
			   .font(.system(size: 16))
		 }
		 .foregroundColor(.white.opacity(0.8))

		 Text(value)
			.font(.system(size: 24, weight: .medium))
			.foregroundColor(.white)
			.minimumScaleFactor(0.7)
			.lineLimit(1)
	  }
	  .frame(maxWidth: .infinity, alignment: .leading)
	  .padding(.vertical, 12)
	  .padding(.horizontal, 16)
	  .background(Color.black.opacity(0.25))
	  .clipShape(RoundedRectangle(cornerRadius: 16))
   }
}
