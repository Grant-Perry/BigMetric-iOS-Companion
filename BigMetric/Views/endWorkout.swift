import SwiftUI
import CoreMotion
import CoreLocation
import HealthKit
import UIKit

struct endWorkout: View {
   @State var unifiedWorkoutManager: UnifiedWorkoutManager
   @Binding var selectedTab: Int

   var screenBounds = WKInterfaceDevice.current().screenBounds
   @State var yardsOrMiles = false
   @State var isStopping   = true
   @State private var isRecording = true

   @State var timeOut         = Color( #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1))
   @State var headerBGColor   = Color( #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))
   @State var headerBGColor2  = Color( #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1))
   @State var isStoppingColor = Color( #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1))

   var body: some View {
	  ZStack {
		 // Background
		 LinearGradient(
			gradient: Gradient(colors: [
			   Color.blue.opacity(0.8),
			   Color.purple.opacity(0.6)
			]),
			startPoint: .topLeading,
			endPoint: .bottomTrailing
		 )
		 .ignoresSafeArea()

		 // Main content
		 VStack(spacing: 16) {
			Image(systemName: "hand.raised.fill")
			   .font(.system(size: 32))
			   .foregroundColor(.white)
			   .padding(.top, 8)

			Text("End Workout?")
			   .font(.system(size: 20, weight: .semibold))
			   .foregroundColor(.white)

			Text("Your progress will be saved")
			   .font(.system(size: 14))
			   .foregroundColor(.white.opacity(0.8))
			   .padding(.bottom, 8)

			VStack(spacing: 12) {
			   // Stop button with icon
			   Button(action: {
				  unifiedWorkoutManager.stopAndFinish()
			   }) {
				  HStack {
					 Image(systemName: "stop.fill")
						.font(.system(size: 14))
					 Text("End Workout")
						.font(.system(size: 16, weight: .medium))
				  }
				  .frame(maxWidth: .infinity)
				  .padding(.vertical, 12)
				  .background(
					 Color.red.opacity(0.9)
						.overlay(Material.thin)
				  )
				  .cornerRadius(20)
			   }

			   // Cancel button with icon
			   Button(action: {
				  selectedTab = 2
			   }) {
				  HStack {
					 Image(systemName: "arrow.uturn.backward")
						.font(.system(size: 14))
					 Text("Continue")
						.font(.system(size: 16, weight: .medium))
				  }
				  .frame(maxWidth: .infinity)
				  .padding(.vertical, 12)
				  .background(
					 Color.gray.opacity(0.3)
						.overlay(Material.ultraThin)
				  )
				  .cornerRadius(20)
			   }
			}
			.padding(.horizontal, 16)
		 }
		 .padding()

		 // Overlay the progress if we're currently saving to HK
		 if unifiedWorkoutManager.isSavingToHealthKit {
			Color.black.opacity(0.7)
			   .edgesIgnoringSafeArea(.all)

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
		 }
	  }
   }
}
