import SwiftUI

/// ``InsideButtonTextView``
/// Displays the distance (in miles or yards) from `UnifiedWorkoutManager`.
/// Preserves your yard/mile logic, formatting, and `showStartText` check.
struct InsideButtonTextView: View {
   
   @Environment(MyOrbViewModel.self) private var myOrbViewModel
   
   /// Use `unifiedWorkoutManager` so the call site can pass `InsideButtonTextView(unifiedWorkoutManager: unifiedWorkoutManager)`
   var unifiedWorkoutManager: UnifiedWorkoutManager
   
   var body: some View {
	  VStack(spacing: 0) {
		 VStack {
			let distanceIn = unifiedWorkoutManager.distance
			if distanceIn > 0 {
			   Group {
				  let distanceInYards = unifiedWorkoutManager.yardsOrMiles
				  ? distanceIn
				  : distanceIn * unifiedWorkoutManager.metersToYards
				  
				  let formattedDistance = String(
					 format: distanceInYards > 100 ? "%.0f" : "%.2f",
					 distanceInYards
				  )
				  // MARK: main distance text on button
				  Text(formattedDistance)
					 .lineLimit(1)
					 .minimumScaleFactor(0.65)
					 .foregroundColor(myOrbViewModel.fontColor)
					 .bold()
					 .shadow(color: .gpWhite, radius: 10, x: 0, y: 0)
				  
				  Text(unifiedWorkoutManager.yardsOrMiles ? "Miles" : "Yards")
					 .font(.caption)
					 .frame(alignment: .trailing)
				  
			   }
			   .shadow(color: .gray, radius: 10, x: 0, y: 0)
			   .font(.system(size: 80))
			   .fontWeight(.bold)
			} else {
			   /// If distance is 0 or not started
			   /// If `showStartText` is true, show "0.00" by default
			   let distanceToDisplay = unifiedWorkoutManager.showStartText
			   ? "0.00"
			   : String(
				  format: "%.2f",
				  unifiedWorkoutManager.yardsOrMiles
				  ? distanceIn
				  : distanceIn * unifiedWorkoutManager.metersToYards
			   )
			   
			   Text(distanceToDisplay)
				  .font(.title)
				  .multilineTextAlignment(.center)
			   
			   Text(unifiedWorkoutManager.yardsOrMiles ? "Miles" : "Yards")
				  .font(.caption)
				  .kerning(1.1)
				  .bold()
			}
		 }
	  }
   }
}
