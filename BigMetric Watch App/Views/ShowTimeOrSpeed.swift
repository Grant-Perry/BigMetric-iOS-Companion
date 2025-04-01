//   ShowTimeOrSpeed.swift
//   BigMetric Watch App
//
//   Created by: Grant Perry on 1/1/24 at 1:23 PM
//     Modified:
//
//  Copyright © Delicious Studios, LLC. - Grant Perry
//

import SwiftUI

// ADD: Display mode enum
enum DisplayMode {
   case speed
   case time
   case pace
}

struct ShowTimeOrSpeed: View {
   @State var unifiedWorkoutManager: UnifiedWorkoutManager
   // ADD: Display mode state
   @State private var displayMode: DisplayMode = .speed

   private var paceString: String {
	  let timeInMinutes = unifiedWorkoutManager.elapsedTime / 60
	  let distanceInMiles = unifiedWorkoutManager.distance

	  guard distanceInMiles > 0 else { return "0:00" }

	  let paceInMinutesPerMile = timeInMinutes / distanceInMiles
	  let minutes = Int(paceInMinutesPerMile)
	  let seconds = Int((paceInMinutesPerMile - Double(minutes)) * 60)

	  return String(format: "%d:%02d", minutes, seconds)
   }

   var body: some View {
	  VStack {
		 if unifiedWorkoutManager.yardsOrMiles {
			HStack {
			   Text(displayMode == .speed ? unifiedWorkoutManager.heading : "")
				  .font(.subheadline)
				  .fontWeight(.bold)
				  .foregroundColor(.white)

			   Button(action: {
				  // CHANGE: Cycle through display modes
				  switch displayMode {
					 case .speed:
						displayMode = .time
					 case .time:
						displayMode = .pace
					 case .pace:
						displayMode = .speed
				  }
			   }) {
				  Group {
					 switch displayMode {
						case .speed:
						   let speedValue = unifiedWorkoutManager.elapsedTime == 0
						   ? 0
						   : (unifiedWorkoutManager.distance / unifiedWorkoutManager.elapsedTime * 3600)
						   Text(speedValue.isNaN || speedValue.isInfinite
								? "0"
								: "\(gpNumFormat.formatNumber(speedValue, 1))")
						   .foregroundColor(.white)
						case .time:
						   Text(unifiedWorkoutManager.formattedTimeString)
							  .foregroundColor(.gpYellow)
						case .pace:
						   Text(paceString)
							  .foregroundColor(.gpGreen)
					 }
				  }
				  .font(displayMode == .time && unifiedWorkoutManager.numTimerHours() > 0
						? .system(size: 28)
						: .system(size: 32))
			   }

			   .buttonStyle(PlainButtonStyle())
			   .background(Color.clear)
			   //			   .frame(width: 95, height: 45)
			   .frame(maxWidth: .infinity)
			   .lineLimit(1)
			   .minimumScaleFactor(0.65)
			   .scaledToFit()


			   Text(displayMode == .speed ? "MPH" : (displayMode == .time ? "Time" : "min/mi"))
				  .font(.system(size: 13))
				  .padding(.top, -2)
				  .padding(.leading, -5)
				  .foregroundColor(.white)
				  .bold()
			}
			.frame(height: 45)
			.horizontallyCentered()

			Spacer()
		 }
	  }
	  .padding(.top, -15)
   }
}

// ADD: Preview
#Preview {
   let mockWorkoutManager = UnifiedWorkoutManager()

   // Set mock data
   mockWorkoutManager.distance = 3.5
   mockWorkoutManager.elapsedTime = 1800 // 30 minutes
   mockWorkoutManager.formattedTimeString = "00:30:00"
   mockWorkoutManager.heading = "N"
   mockWorkoutManager.yardsOrMiles = true

   return ShowTimeOrSpeed(unifiedWorkoutManager: mockWorkoutManager)
	  .environmentObject(mockWorkoutManager)
	  .background(Color.black) // Adding dark background for better visibility
}
