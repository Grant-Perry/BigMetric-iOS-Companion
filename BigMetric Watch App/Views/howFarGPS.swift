import SwiftUI
import CoreMotion
import CoreLocation
import HealthKit
import WatchConnectivity

struct howFarGPS: View {
#if os(watchOS)
   @State var screenBounds = WKInterfaceDevice.current().screenBounds
#else
   @State var screenBounds = UIScreen.main.bounds
#endif
   
   @Environment(\.colorScheme) var colorScheme
   
   @ObservedObject var unifiedWorkoutManager: UnifiedWorkoutManager
   
   @State var debug            = false
   @State var resetDist        = false
   @State var isAuthorized     = false
   @State var isHealthUpdate   = false
   @State var debugStr         = ""
   @State var gpsLoc           = "GPS"
   @State var selectedDistance = "Miles"
   
   // MARK: - Colors
   @State var gradStopColor      = Color(#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1))
   @State var bgYardsStopTop      = Color(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1))
   @State var bgYardsStopBottom   = Color( #colorLiteral(red: 1, green: 0.1271572973, blue: 0.969772532, alpha: 1))
   @State var bgYardsStartTop     = Color( #colorLiteral(red: 1, green: 0.5212053061, blue: 1, alpha: 1))
   @State var bgYardsStartBottom  = Color( #colorLiteral(red: 1, green: 0.1271572973, blue: 0.969772532, alpha: 1))
   @State var bgMilesStopTop      = Color( #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
   @State var bgMilesStopBottom   = Color( #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
   @State var bgMilesStartTop     = Color( #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1))
   @State var bgMilesStartBottom  = Color( #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1))
   @State var timeOut            = Color( #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1))
   @State var backColor          = Color( #colorLiteral(red: 0.8699219823, green: 0.9528884292, blue: 0.8191569448, alpha: 1))
   @State var isHealthUpdateOn   = Color( #colorLiteral(red: 0.2760013003, green: 0.4030833564, blue: 0.8549019694, alpha: 1))
   @State var isUpdatingOn       = Color( #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1))
   @State var isUpdatingOnStop   = Color( #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1))
   @State var isUpdatingOff      = Color( #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
   @State var isUpdatingOffStop  = Color( #colorLiteral(red: 0.9260191787, green: 0.1247814497, blue: 0.4070666561, alpha: 1))
   @State var isRecordingColor   = Color( #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1))
   
   var timePadding = 70.0
   var width       = 30.0
   var height      = 30.0
   
   /// Computed
   var isUp: Bool {
	  unifiedWorkoutManager.workoutState == .running
   }
   var isRecording: Bool {
	  unifiedWorkoutManager.weIsRecording
   }
   var isPaused: Bool {
	  unifiedWorkoutManager.workoutState == .paused
   }
   
   @State private var lastDoubleTapTime: Date = .distantPast
   
   var body: some View {
	  VStack(alignment: .center, spacing: 0) {
		 VStack(spacing: 0) {
			/// Top spacer
			VStack {}.frame(height: 120)
			
			/// The main content
			VStack(alignment: .center, spacing: 0) {
			   
			   /// The main big start/stop button with orb
			   ButtonView(
				  stateBtnColor: isRecording ? (isUp ? isRecordingColor : .white) : .black,
				  startColor: !isRecording
				  ? (unifiedWorkoutManager.yardsOrMiles ? bgMilesStopTop : bgYardsStopTop)
				  : (unifiedWorkoutManager.yardsOrMiles ? bgMilesStartTop : bgYardsStartTop),
				  endColor: !isRecording
				  ? (unifiedWorkoutManager.yardsOrMiles ? bgMilesStopBottom : bgYardsStopBottom)
				  : (unifiedWorkoutManager.yardsOrMiles ? bgMilesStartBottom : bgYardsStartBottom),
				  isUp: self.isUp,
				  screenBounds: self.screenBounds
			   )
			   .scaleEffect(1.18)
			   
			   .overlay(
				  /// Double tap to start the workout HERE
				  VStack {
					 DoubleClickButton(action: {
						/// Debounce logic: only allow action if enough time has passed
						if Date().timeIntervalSince(lastDoubleTapTime) > 0.5 {
						   lastDoubleTapTime = Date()
						   
						   switch unifiedWorkoutManager.workoutState {
							  case .notStarted:
								 if unifiedWorkoutManager.isBeep {
									PlayHaptic.tap(.start)
								 }
								 unifiedWorkoutManager.startNewWorkout()
								 
							  case .running:
								 if unifiedWorkoutManager.isBeep {
									PlayHaptic.tap(.stop)
								 }
								 unifiedWorkoutManager.pauseWorkout()
								 
							  case .paused:
								 if unifiedWorkoutManager.isBeep {
									PlayHaptic.tap(.start)
								 }
								 unifiedWorkoutManager.resumeWorkout()
								 
							  case .ended:
								 /// no-op or re-init if desired
								 break
						   }
						}
					 }) {
						InsideButtonTextView(unifiedWorkoutManager: unifiedWorkoutManager)
					 }
				  }
					 .tint(Color(.clear))
					 .foregroundColor(.white)
			   )
			   .padding(.top, -65)
			   
			   Spacer()
			   
			   /// Show time or speed
			   ShowTimeOrSpeed(
				  unifiedWorkoutManager: unifiedWorkoutManager
			   )
			   Spacer()
			}
			/// move these back inside the next VStack if you want to implement
			/// Yards button
			//				  HStack {
			//					 DoubleClickButton(action: {
			//						unifiedWorkoutManager.showStartText = true
			//						unifiedWorkoutManager.yardsOrMiles = false
			//					 }) {
			//						Image(systemName: "y.circle.fill")
			//						   .font(.footnote)
			//						   .foregroundColor(.white)
			//						   .cornerRadius(10)
			//					 }
			//					 .frame(width: width, height: height, alignment: .center)
			//					 .background(
			//						LinearGradient(
			//						   gradient: Gradient(colors: [bgYardsStopTop, bgYardsStopBottom]),
			//						   startPoint: .bottomLeading,
			//						   endPoint: .topLeading
			//						)
			//					 )
			//					 .cornerRadius(15)
			//					 .overlay(
			//						RoundedRectangle(cornerRadius: 15)
			//						   .stroke(
			//							  unifiedWorkoutManager.yardsOrMiles ? .black : .white,
			//							  lineWidth: 3
			//						   )
			//					 )
			//				  }
			
			/// Miles button
			//				  HStack {
			//					 DoubleClickButton(action: {
			//						unifiedWorkoutManager.isSpeed = false
			//						unifiedWorkoutManager.yardsOrMiles = true
			//						unifiedWorkoutManager.showStartText = true
			//					 }) {
			//						Image(systemName: "m.circle.fill")
			//						   .font(.footnote)
			//						   .foregroundColor(.white)
			//						   .cornerRadius(10)
			//					 }
			//					 .frame(width: width, height: height, alignment: .center)
			//					 .background(
			//						LinearGradient(
			//						   gradient: Gradient(colors: [
			//							  unifiedWorkoutManager.yardsOrMiles
			//							  ? (!isRecording ? bgMilesStopTop : bgMilesStartTop)
			//							  : bgMilesStopTop,
			//							  unifiedWorkoutManager.yardsOrMiles
			//							  ? (!isRecording ? bgMilesStopBottom : bgMilesStartBottom)
			//							  : bgMilesStopBottom
			//						   ]),
			//						   startPoint: .bottomLeading,
			//						   endPoint: .topLeading
			//						)
			//					 )
			//					 .cornerRadius(15)
			//					 .overlay(
			//						RoundedRectangle(cornerRadius: 15)
			//						   .stroke(
			//							  !unifiedWorkoutManager.yardsOrMiles ? .black : .white,
			//							  lineWidth: 3
			//						   )
			//					 )
			//				  }
			
			/// The bottom row for ± reset and yards/miles toggles
			VStack {
			   HStack(alignment: .center, spacing: 7) {
				  HStack {
					 DoubleClickButton(action: {
						unifiedWorkoutManager.showStartText = true
						unifiedWorkoutManager.resetForNewWorkout()
						unifiedWorkoutManager.forceLocationRefresh()
					 }) {
						Image(systemName: "repeat.circle.fill")
						   .resizable()
						   .aspectRatio(contentMode: .fit)
						   .frame(width: 20, height: 20)
						   .foregroundColor(.white)
					 }
					 .frame(width: 25, height: 25, alignment: .center)
					 					 .background(
					 						LinearGradient(
											 gradient: Gradient(
												colors: [.gpPink, .gpBlue]
											 ),
					 						   startPoint: .bottomLeading,
					 						   endPoint: .topLeading
					 						)
					 					 )
										 .clipShape(.circle)
//					 					 .cornerRadius(5)
					 
				  }
				  //				  .frame(width: .infinity)
				  .padding(.leading)
				  .offset(x: -100)

				  /// New button for walking trigger
				  HStack {
					 DoubleClickButton(action: {
						// Action for the new button can be added here
					 }) {
						Image(systemName: "figure.run.circle")
						   .font(.footnote)
						   .foregroundColor(unifiedWorkoutManager.isWalkingTriggerOn ? .gpGreen : .gray)
						   .cornerRadius(10)
					 }
					 .frame(width: width + 5, height: height + 5, alignment: .center)
					 .cornerRadius(15)
				  }
			   }
			   .frame(width: (screenBounds.width / 0.5), height: 100)
			}
			//			.background(.white).opacity(0.1)
			.padding(.top, -50)
			.offset(x: 55)
		 }
		 
		 ZStack {
			HStack {
			   HStack {
				  GPSIconView(
					 accuracy: Int(unifiedWorkoutManager.GPSAccuracy),
					 size: 17.0
				  )
				  .frame(width: 25, height: 40)
				  .offset(x: 75, y: (-screenBounds.height / 2  - 20))
			   }
			}
			.frame(height: 39)
			.background(.black)
		 }
	  }
	  .preferredColorScheme(.dark)
	  // MARK:  Writing Data overlay
	  if unifiedWorkoutManager.isSavingToHealthKit {
		 Color.black.opacity(0.4)
			.ignoresSafeArea()
		 VStack(spacing: 12) {
			Text("Writing Workout Data...")
			   .font(.headline)
			   .foregroundColor(.white)
			ProgressView()
			   .progressViewStyle(CircularProgressViewStyle(tint: .white))
		 }
		 .padding(20)
		 .background(Color.black.opacity(0.7))
		 .cornerRadius(12)
	  }
   }
   
   /// For debug usage only.
   func updateDebugStr(_ var1: Bool, _ var2: Bool) {
	  debugStr = "YM: \(String(var1)) - isRec: \(String(var2))"
   }
}

struct howFarGPS_Previews: PreviewProvider {
   static var previews: some View {
	  let dummyManager = UnifiedWorkoutManager()
	  dummyManager.yardsOrMiles = true
	  dummyManager.workoutState = .notStarted
	  dummyManager.weIsRecording = false
	  dummyManager.isWalkingTriggerOn = false
	  dummyManager.GPSAccuracy = 5
	  dummyManager.isBeep = false
	  
	  return howFarGPS(unifiedWorkoutManager: dummyManager)
		 .previewDisplayName("Preview - howFarGPS")
   }
}
