//
//  AltitudePointChart.swift
//  howFar Watch App
//
//  Replaces DistanceTracker references with UnifiedWorkoutManager
//  If your chart used distanceTracker.altitudes, unify them to unifiedWorkoutManager.altitudes
//

import SwiftUI
import Charts

struct AltitudePointChart: View {

   /// old code said distanceTracker. Now unify:
   @State var unifiedWorkoutManager: UnifiedWorkoutManager

   var body: some View {
	  VStack {
		 Text("Altitude Chart")
			.horizontallyCentered()

		 /// If you used SwiftUI Charts, referencing altitudes array
		 /// from unifiedWorkoutManager:
		 ScrollView(.horizontal) {
			Chart(unifiedWorkoutManager.altitudes) { altPoint in
			   BarMark(
				  x: .value("Distance", altPoint.dist),
				  y: .value("Altitude", altPoint.value)
			   )
			}
		 }
		 .frame(width: WKInterfaceDevice.current().screenBounds.width * 0.95,
				height: WKInterfaceDevice.current().screenBounds.height * 0.5)
	  }
	  .padding()
   }
}
