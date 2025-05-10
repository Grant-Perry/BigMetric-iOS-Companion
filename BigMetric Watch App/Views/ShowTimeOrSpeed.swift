//   ShowTimeOrSpeed.swift
//   BigMetric Watch App
//
//   Created by: Grant Perry on 1/1/24 at 1:23 PM
//     Modified:
//
//  Copyright Delicious Studios, LLC. - Grant Perry
//

import SwiftUI

enum DisplayMode {
   case speed
   case time
   case pace
}

struct ShowTimeOrSpeed: View {
   @State var unifiedWorkoutManager: UnifiedWorkoutManager
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

   private var speedValue: Double {
	  guard unifiedWorkoutManager.elapsedTime > 0 else { return 0 }
	  let speed = (unifiedWorkoutManager.distance / unifiedWorkoutManager.elapsedTime) * 3600
	  return speed.isNaN || speed.isInfinite ? 0 : speed
   }

   private var hasHours: Bool {
	  let components = unifiedWorkoutManager.formattedTimeString.split(separator: ":")
	  return components.count > 2
   }

   private var displayText: Text {
	  switch displayMode {
		 case .speed:
			return Text(gpNumFormat.formatNumber(speedValue, 1))
		 case .time:
			return Text(unifiedWorkoutManager.formattedTimeString)
			   .foregroundColor(.gpYellow)
		 case .pace:
			return Text(paceString)
			   .foregroundColor(.gpGreen)
	  }
   }

   var body: some View {
	  VStack {
		 if unifiedWorkoutManager.yardsOrMiles {
			HStack {
			   // Heading
			   Text(displayMode == .speed ? unifiedWorkoutManager.heading : "")
				  .font(.subheadline)
				  .fontWeight(.bold)
				  .foregroundColor(.white)

			   Button(action: {
				  switch displayMode {
					 case .speed:
						displayMode = .time
					 case .time:
						displayMode = .pace
					 case .pace:
						displayMode = .speed
				  }
			   }) {
				  displayText
					 .foregroundColor(displayMode == .speed ? .white : nil)
					 .font(displayMode == .time && hasHours
						   ? .system(size: 28)
						   : .system(size: 32))
			   }
			   .buttonStyle(PlainButtonStyle())
			   .background(Color.clear)
			   //               .frame(width: 95, height: 45)
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
