import SwiftUI
import CoreMotion
import CoreLocation
import HealthKit
import UIKit

struct endWorkout: View {
   @State var unifiedWorkoutManager: UnifiedWorkoutManager
   @Binding var selectedTab: Int

   var body: some View {
	  ZStack {
		 // Background gradient matching summary
		 LinearGradient(
			gradient: Gradient(colors: [
			   .purple.opacity(0.8),
			   .blue.opacity(0.6),
			   .purple.opacity(0.3)
			]),
			startPoint: .topLeading,
			endPoint: .bottomTrailing
		 )
		 .ignoresSafeArea()

		 ScrollView(.vertical) {
			VStack(spacing: 20) {
			   // End Workout Card
			   VStack(spacing: 16) {
				  // Icon and Title
				  VStack(spacing: 4) {
					 Image(systemName: "hand.raised.fill")
						.font(.system(size: 32))
						.foregroundStyle(.white)
						.padding(.top, 8)

					 Text("End Workout?")
						.font(.system(size: 20, weight: .semibold))
						.foregroundColor(.white)

					 Text("Your progress will be saved")
						.font(.system(size: 14))
						.foregroundColor(.white.opacity(0.8))
				  }
				  .padding(.vertical, 8)
				  .frame(maxWidth: .infinity)
				  .background(Color.white.opacity(0.15))
				  .cornerRadius(15)

				  // End Button
				  Button(action: {
					 unifiedWorkoutManager.stopAndFinish()
				  }) {
					 HStack {
						Image(systemName: "stop.fill")
						Text("End")
					 }
					 .font(.system(size: 20, weight: .semibold))
					 .foregroundColor(.white)
					 .frame(maxWidth: .infinity)
					 .padding(.vertical, 12)
					 .background(Color.red.opacity(0.3))
					 .cornerRadius(15)
				  }

				  // Continue Button
				  Button(action: {
					 selectedTab = 2
				  }) {
					 HStack {
						Image(systemName: "arrow.counterclockwise")
						Text("Continue")
					 }
					 .font(.system(size: 20, weight: .semibold))
					 .foregroundColor(.white)
					 .frame(maxWidth: .infinity)
					 .padding(.vertical, 12)
					 .background(Color.white.opacity(0.15))
					 .cornerRadius(15)
				  }
			   }
			   .padding(.horizontal, 16)
			   .padding(.vertical, 12)
			   .background(
				  RoundedRectangle(cornerRadius: 20)
					 .fill(Color.black.opacity(0.2))
			   )
			   .padding(.horizontal)
			}
			.padding(.vertical)
		 }

		 // Saving overlay
		 if unifiedWorkoutManager.isSavingToHealthKit {
			Color.black.opacity(0.7)
			   .edgesIgnoringSafeArea(.all)
			   .transition(.opacity)

			VStack(spacing: 12) {
			   ProgressView()
				  .progressViewStyle(CircularProgressViewStyle(tint: .white))
				  .scaleEffect(1.2)

			   Text("Saving Workout...")
				  .font(.system(size: 16, weight: .medium))
				  .foregroundColor(.white)
			}
			.padding(24)
			.background(Color.black.opacity(0.6))
			.cornerRadius(16)
			.transition(.scale.combined(with: .opacity))
		 }
	  }
	  .animation(.easeInOut, value: unifiedWorkoutManager.isSavingToHealthKit)
   }
}
