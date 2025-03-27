//   ShowTimeOrSpeed.swift
//   BigMetric Watch App
//
//   Created by: Grant Perry on 1/1/24 at 1:23 PM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI

struct ShowTimeOrSpeed: View {
   @State var unifiedWorkoutManager: UnifiedWorkoutManager

   var body: some View {
	  VStack {
		 if unifiedWorkoutManager.yardsOrMiles {
			HStack {
//			   Text(!unifiedWorkoutManager.isSpeed ? "" : unifiedWorkoutManager.heading) // uncomment to show degrees instead
			   Text(unifiedWorkoutManager.isSpeed ? unifiedWorkoutManager.heading : "")
				  .font(.callout)
				  .fontWeight(.bold)
				  .foregroundColor(.white)

			   Button(action: {
				  unifiedWorkoutManager.isSpeed.toggle()
			   }) {
				  let speedValue = unifiedWorkoutManager.elapsedTime == 0
				  ? 0
				  : (unifiedWorkoutManager.distance / unifiedWorkoutManager.elapsedTime * 3600)
				  Text(
					 unifiedWorkoutManager.isSpeed
					 ? (speedValue.isNaN || speedValue.isInfinite
						? "0"
						: "\(gpNumFormat.formatNumber(speedValue, 1))")
					 : unifiedWorkoutManager.formattedTimeString
				  )
				  .foregroundColor(unifiedWorkoutManager.isSpeed ? .white : .gpYellow)
				  .font(
					 unifiedWorkoutManager.isSpeed
					 ? .title2
					 : (unifiedWorkoutManager.numTimerHours() > 0 ? .title3 : .title2)
				  )
			   }
			   .buttonStyle(PlainButtonStyle())
			   .background(Color.clear)
			   .frame(width: 95, height: 45)

			   Text(unifiedWorkoutManager.isSpeed ? "MPH" : "Time")
				  .font(.system(size: 13))
				  .padding(.top, -16)
				  .padding(.leading, -10)
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
