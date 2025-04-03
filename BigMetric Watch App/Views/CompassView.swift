import SwiftUI
import CoreLocation

struct CompassView: View {
   @State var screenBounds = WKInterfaceDevice.current().screenBounds
   @ObservedObject var unifiedWorkoutManager: UnifiedWorkoutManager
   @State private var rotateBGMode: Bool = false

   var body: some View {
	  ZStack {
		 Image("CompassBG")
			.resizable()
			.scaledToFit()
			.frame(width: screenBounds.width * 0.9, height: screenBounds.width * 0.9)

		 Circle()
			.stroke(Color.white.opacity(0.5), lineWidth: 4)
			.frame(width: screenBounds.width * 0.95, height: screenBounds.width * 0.95)

		 Circle()
			.trim(from: 0.125, to: 0.375)
			.stroke(Color.green.opacity(0.7), lineWidth: 6)
			.frame(width: screenBounds.width * 0.95, height: screenBounds.width * 0.95)
			.rotationEffect(.degrees(unifiedWorkoutManager.course - 180))

		 Image("greenArrow")
			.resizable()
			.scaledToFit()
			.frame(width: 50, height: 110)
			.foregroundColor(.green)
			.rotationEffect(.degrees(unifiedWorkoutManager.course))
			.opacity(0.95)
			.scaleEffect(1.2)

		 Text(unifiedWorkoutManager.heading)
			.font(.title3)
			.foregroundColor(.white)
			.bold()
			.shadow(radius: 15)
			.padding(8)
			.background(Circle().fill(Color.black.opacity(0.25)))

		 VStack {
			Spacer()
			HStack {
			   Text("\(Int(unifiedWorkoutManager.course))°")
				  .font(.system(size: 25))
				  .offset(y: 26)
				  .foregroundColor(.gpMinty)
			}
		 }
	  }
	  .font(.headline)
	  .scaleEffect(0.97)
	  .onTapGesture(count: 2) {
		 withAnimation(.easeInOut(duration: 0.3)) {
			rotateBGMode.toggle()
		 }
	  }
	  .onAppear {
		 unifiedWorkoutManager.LMDelegate.delegate = unifiedWorkoutManager
		 unifiedWorkoutManager.LMDelegate.desiredAccuracy = kCLLocationAccuracyBest
		 unifiedWorkoutManager.LMDelegate.headingFilter = 5
		 unifiedWorkoutManager.LMDelegate.headingOrientation = .portrait
		 unifiedWorkoutManager.LMDelegate.startUpdatingLocation()
		 unifiedWorkoutManager.LMDelegate.startUpdatingHeading()
	  }
	  .onDisappear {
		 unifiedWorkoutManager.LMDelegate.stopUpdatingHeading()
		 unifiedWorkoutManager.LMDelegate.stopUpdatingLocation()
	  }
   }
}

#Preview {
   let mockWorkoutManager = UnifiedWorkoutManager()
   mockWorkoutManager.course = 45.0
   mockWorkoutManager.heading = "NE"

   return CompassView(
	  unifiedWorkoutManager: mockWorkoutManager
   )
   .frame(width: WKInterfaceDevice.current().screenBounds.width)
   .background(Color.black)
}
