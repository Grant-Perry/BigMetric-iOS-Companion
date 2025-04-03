import SwiftUI

struct WorkoutRouteMetricsGridView: View {
    let formattedTotalTime: String
    let distance: Double
    let weatherTemp: String?
    let formatPaceMinMi: () -> String
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 8) {
            WorkoutRouteMetricView(
                title: "Duration",
                value: formattedTotalTime,
                icon: "clock.fill"
            )
            .transition(.scale.combined(with: .opacity))
            
            WorkoutRouteMetricView(
                title: "Distance",
                value: String(format: "%.2f mi", distance),
                icon: "figure.walk"
            )
            .transition(.scale.combined(with: .opacity))
            
            WorkoutRouteMetricView(
                title: "Pace",
                value: formatPaceMinMi(),
                icon: "speedometer"
            )
            .transition(.scale.combined(with: .opacity))
            
            if let temp = weatherTemp {
                WorkoutRouteMetricView(
                    title: "Temperature",
                    value: "\(temp)°",
                    icon: "thermometer"
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
}
