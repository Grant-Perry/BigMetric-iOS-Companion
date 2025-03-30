import SwiftUI
import HealthKit

struct WorkoutMetricsView: View {
   var workout: WorkoutCore
   var metricMeta: MetricMeta
   @ObservedObject var polyViewModel: PolyViewModel
   
   var body: some View {
	  VStack(spacing: 12) {
		 HStack(alignment: .top, spacing: 16) {
			//  MARK: - Left Section (City and Time)
			VStack(alignment: .leading, spacing: 8) {
			   Text(metricMeta.cityName)
				  .font(.system(size: 32))
				  .fontWeight(.bold)
				  .lineLimit(1)
				  .minimumScaleFactor(0.8)
				  .padding(.top, 8)
			   
			   HStack(spacing: 4) {
				  Image(systemName: "clock")
					 .font(.system(size: 14))
				  Text(metricMeta.totalTime)
					 .font(.system(size: 16))
			   }
			   
			   // MARK: - Navigation Link to MetricsView
			   NavigationLink(destination: MetricsView(workout: workout, metricMeta: metricMeta)) {
				  HStack {
					 Image(systemName: "chart.bar.fill")
						.font(.system(size: 16))
					 Text("View Details")
						.font(.system(size: 14))
						.fontWeight(.medium)
				  }
				  .foregroundColor(.white)
				  .padding(.vertical, 6)
				  .padding(.horizontal, 12)
				  .background(Color.white.opacity(0.2))
				  .cornerRadius(16)
			   }
			   .padding(.top, 4)
			}
			
			Spacer()
			
			// MARK: - Right Section (Date and Stats)
			VStack(alignment: .trailing, spacing: 6) {
			   // Date and Time Group
			   VStack(alignment: .trailing, spacing: 2) {
				  Text(dateFormatter.string(from: metricMeta.startDate))
					 .font(.subheadline)
				  Text(timeFormatter.string(from: metricMeta.startDate))
					 .font(.caption)
					 .opacity(0.9)
			   }
			   
			   Divider()
				  .frame(width: 40, height: 1)
				  .background(Color.white.opacity(0.5))
				  .padding(.vertical, 4)
			   
			   // Stats Group
			   VStack(alignment: .trailing, spacing: 6) {
				  // Distance with icon
				  HStack(spacing: 6) {
					 Image(systemName: "figure.run")
					 
					 Text("Distance:")
						.font(.caption)
					 Text("\(String(format: "%.2f", workout.distance)) mi")
						.fontWeight(.semibold)
				  }
				  .font(.system(size: 14))
				  .frame(maxWidth: .infinity)
				  .lineLimit(1)
				  .minimumScaleFactor(0.5)
				  .scaledToFit()
				  
				  // Average Speed with icon
				  if let speed = metricMeta.averageSpeed {
					 HStack(spacing: 6) {
						Image(systemName: "speedometer")
						//						   .font(.system(size: 14))
						Text("Avg Speed:")
						   .font(.caption)
						Text("\(String(format: "%.1f", speed)) mph")
						   .fontWeight(.semibold)
					 }
					 .font(.system(size: 14))
					 .frame(maxWidth: .infinity)
					 .lineLimit(1)
					 .minimumScaleFactor(0.5)
					 .scaledToFit()
					 
				  }
			   }
			}
		 }
		 .padding(.horizontal, 20)
		 .padding(.vertical, 16)
	  }
	  .frame(height: 180)
	  .background(WeatherGradient(from: metricMeta.weatherSymbol ?? "sun.max").gradient)
	  .foregroundColor(.white)
	  .cornerRadius(12)
	  .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
   }
   
   private var dateFormatter: DateFormatter {
	  let formatter = DateFormatter()
	  formatter.dateStyle = .long
	  return formatter
   }
   
   private var timeFormatter: DateFormatter {
	  let formatter = DateFormatter()
	  formatter.dateFormat = "h:mm a"
	  return formatter
   }
}
