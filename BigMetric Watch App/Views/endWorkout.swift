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

		 VStack(spacing: 12) {
			// Icon and Title
			VStack(spacing: 4) {
			   Image(systemName: "hand.raised.fill")
				  .font(.system(size: 28))
				  .foregroundStyle(.white)
				  .padding(.top, 4)

			   Text("End Workout?")
				  .font(.system(size: 18, weight: .semibold))
				  .foregroundColor(.white)

			   Text("Your progress will be saved")
				  .font(.system(size: 12))
				  .foregroundColor(.white.opacity(0.8))
			}
			.padding(.vertical, 6)
			.frame(maxWidth: .infinity)
			.background(Color.white.opacity(0.15))
			.cornerRadius(15)

			// End Button - Made more prominent
			Button(action: {
			   unifiedWorkoutManager.stopAndFinish()
			}) {
			   HStack {
				  Image(systemName: "stop.fill")
				  Text("End Workout")
			   }
			   .font(.system(size: 20, weight: .bold))
			   .foregroundColor(.white)
			   .frame(maxWidth: .infinity)
			   .padding(.vertical, 14)
			   .background(Color.red.opacity(0.6))
			   .cornerRadius(15)
			}

			// Continue Button - Made less prominent
			Button(action: {
			   selectedTab = 2
			}) {
			   HStack {
				  Image(systemName: "arrow.counterclockwise")
				  Text("Continue")
			   }
			   .font(.system(size: 16, weight: .medium))
			   .foregroundColor(.white.opacity(0.9))
			   .frame(maxWidth: .infinity)
			   .padding(.vertical, 10)
			   .background(Color.white.opacity(0.15))
			   .cornerRadius(15)
			}
		 }
		 .padding(.horizontal, 16)
		 .padding(.vertical, 8)

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
