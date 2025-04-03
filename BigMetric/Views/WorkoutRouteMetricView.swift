import SwiftUI

struct WorkoutRouteMetricView: View {
   let title: String
   let value: String
   let icon: String

   var body: some View {
	  VStack(spacing: 2) {
		 HStack(spacing: 4) {
			Image(systemName: icon)
			   .font(.system(size: 13))
			   .foregroundColor(.white)
			Text(title)
			   .font(.system(size: 13, weight: .medium))
			   .foregroundColor(.white)
		 }
		 Text(value)
			.font(.system(size: 20, weight: .semibold))
			.foregroundColor(.white)
	  }
	  .frame(maxWidth: .infinity)
	  .padding(.vertical, 8)
	  .background(Color.white.opacity(0.35))
	  .cornerRadius(8)
   }
}
