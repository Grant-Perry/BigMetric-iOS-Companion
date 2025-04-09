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
        ], spacing: 8) {
            WorkoutMetricCard(title: "Duration", value: formattedTotalTime, icon: "clock.fill", weatherSymbol: weatherSymbol)
            WorkoutMetricCard(title: "Distance", value: String(format: "%.2f mi", distance), icon: "figure.walk", weatherSymbol: weatherSymbol)
            WorkoutMetricCard(title: "Pace", value: pace, icon: "speedometer", weatherSymbol: weatherSymbol)
            
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
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.black.opacity(0.15))
        .cornerRadius(16)
    }
}