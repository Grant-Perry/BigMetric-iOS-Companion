//
//  AltitudeView.swift
//  howFar Watch App
//
//  Created by Grant Perry on 5/13/23.
//  Modified to reference UnifiedWorkoutManager instead of DistanceTracker.
//  Yards/Miles logic, style, & layout remain unchanged.
//

import SwiftUI
import CoreMotion
import Combine

struct AltitudeView: View {

   /// Replacing old distanceTracker with the new unifiedWorkoutManager
   @State var unifiedWorkoutManager: UnifiedWorkoutManager

   @State var isShowingSheet = false
   @State var screenBounds = WKInterfaceDevice.current().screenBounds

   /// If you used some local altitude manager, keep it:
   @StateObject private var altitudeManager = AltitudeManager()

   //// ------------- Main Button Colors --------------------
   var bgYardsStopTop =  Color(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))
   var bgYardsStopBottom = Color(#colorLiteral(red: 1, green: 0.1271572973, blue: 0.969772532, alpha: 1))
   var bgYardsStartTop = Color(#colorLiteral(red: 1, green: 0.5212053061, blue: 1, alpha: 1))
   var bgYardsStartBottom = Color(#colorLiteral(red: 1, green: 0.1271572973, blue: 0.969772532, alpha: 1))
   var bgMilesStopTop =  Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1))
   var bgMilesStopBottom = Color(#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1))
   var bgMilesStartTop =  Color(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
   var bgMilesStartBottom = Color(#colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1))
   var isRecordingColor = Color(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1))

   /// If user toggles the main button
   var isUp: Bool {
	  // If you had old code like distanceTracker.isUpdating, unify it to e.g. unifiedWorkoutManager.isLocateMgr or weIsRecording
	  // or any relevant property. If "isUpdating" doesn't exist, pick the appropriate one:
	  return unifiedWorkoutManager.isLocateMgr
   }
   var isRecording: Bool {
	  return unifiedWorkoutManager.weIsRecording
   }

   var body: some View {
	  VStack {
		 /// If there's no distance or altitude data yet
		 if unifiedWorkoutManager.distance == 0 {
			ZStack {
			   LocationProgressView(message: "Altitude")
			}
		 } else {
			Button(action: {
			   self.isShowingSheet.toggle()
			}) {
			   ButtonView(
				  /// old code used distanceTracker for isRecording check, now we unify
				  stateBtnColor: isRecording ? (isUp ? isRecordingColor : .white) : .black,
				  startColor:  !isRecording
				  ? (unifiedWorkoutManager.yardsOrMiles ? bgMilesStopTop : bgYardsStopTop)
				  : (unifiedWorkoutManager.yardsOrMiles ? bgMilesStartTop : bgYardsStartTop),
				  endColor:    !isRecording
				  ? (unifiedWorkoutManager.yardsOrMiles ? bgMilesStopBottom : bgYardsStopBottom)
				  : (unifiedWorkoutManager.yardsOrMiles ? bgMilesStartBottom : bgYardsStartBottom),
				  isUp: self.isUp,
				  screenBounds: self.screenBounds
			   )
			   .scaleEffect(1.2)
			   .overlay(
				  VStack {
					 // Use the formatted altitudeString directly
					 Text(altitudeManager.altitudeString)
						.font(.title2)
						.bold()
						.lineLimit(1)
						.minimumScaleFactor(0.55)
						.shadow(radius: 8)

					 Image(systemName: "mountain.2")
					 Text("Altitude")
						.font(.footnote)
				  }
			   )
			}
			.sheet(isPresented: $isShowingSheet) {
			   /// If old code used AltitudePointChart(distanceTracker: distanceTracker)
			   /// unify it to AltitudePointChart(unifiedWorkoutManager: unifiedWorkoutManager)
			   AltitudePointChart(unifiedWorkoutManager: unifiedWorkoutManager)
			}
		 }
	  }
	  // If you want the altitudeManager to start or stop
	  .onAppear {
		 altitudeManager.startUpdates()
	  }
	  .onDisappear {
		 altitudeManager.stopUpdates()
	  }
   }
}
