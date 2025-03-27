import SwiftUI
import CoreLocation

struct CompassView: View {
   // The screen bounds for layout calculations.
   @State var screenBounds = WKInterfaceDevice.current().screenBounds

   // External dependencies.
   @State var unifiedWorkoutManager: UnifiedWorkoutManager
   @State var heading: Double
   @State var routeHeading: Double

   // Background colors for potential use (currently not modified).
   @State var bgStart = Color(#colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1))
   @State var bgStop  = Color(#colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1))

   /// New state variable controlling the rotation mode:
   /// - false (default): The background is static and the needle rotates with the compass reading.
   /// - true: The background rotates with the compass reading and the needle remains static.
   @State private var rotateBGMode: Bool = false

   var body: some View {
	  ZStack {
		 // The compass background image.
		 // In default mode, it remains static.
		 // When rotateBGMode is true, it rotates according to the compass reading.
		 Image("CompassBG")
			.resizable()
			.scaledToFit()
			.frame(width: screenBounds.width * 0.9, height: screenBounds.width * 0.9)
			.rotationEffect(rotateBGMode ? .degrees(-unifiedWorkoutManager.course) : .degrees(0))
			.animation(.easeInOut, value: rotateBGMode ? unifiedWorkoutManager.course : 0)

		 // Circular outer ring matching a reference example.
		 Circle()
			.stroke(Color.white.opacity(0.5), lineWidth: 4)
			.frame(width: screenBounds.width * 0.95, height: screenBounds.width * 0.95)

		 // Green arc indicator along the outer edge.
		 // This arc rotates along with the course.
		 Circle()
			.trim(from: 0.125, to: 0.375) // 90-degree arc centered at the top.
			.stroke(Color.green.opacity(0.7), lineWidth: 6)
			.frame(width: screenBounds.width * 0.95, height: screenBounds.width * 0.95)
			.rotationEffect(.degrees(unifiedWorkoutManager.course + 180))

		 // The compass arrow (needle).
		 // When rotateBGMode is false, the arrow rotates with the course.
		 // When rotateBGMode is true, the arrow remains static.
		 Image("greenArrow")
			.resizable()
			.scaledToFit()
			.frame(width: 50, height: 110) // Adjusted size.
			.foregroundColor(.green)
			.rotationEffect(rotateBGMode ? .degrees(0) : .degrees(unifiedWorkoutManager.course))
			.opacity(0.95)
			.scaleEffect(1.2)

		 // Heading text overlay with gradient background.
		 Text(unifiedWorkoutManager.heading)
			.font(.title3)
			.foregroundColor(.black)
			.bold()
			.shadow(radius: 15)
			.padding(8)
			.background(Circle().fill(Color.white.opacity(0.25)))

		 // Additional course value display at the bottom.
		 VStack {
			Spacer()
			HStack {
			   HStack {
				  Text("\(gpNumFormat.formatNumber(unifiedWorkoutManager.course, 2))")
					 .font(.system(size: 25))
					 .offset(y: 26)
			   }
			   HStack {
				  Text("°")
					 .font(.system(size: 22))
					 .offset(x: -3, y: 32)
					 .fontWeight(.thin)
			   }
			}
			.foregroundColor(.gpMinty)
		 }
	  }
	  .font(.headline)
	  // Attach a double-tap gesture to the entire compass view.
	  // When double tapped, the mode toggles between:
	  //   • Static background / rotating needle, and
	  //   • Rotating background / static needle.
	  .onTapGesture(count: 2) {
		 withAnimation {
			rotateBGMode.toggle()
		 }
	  }
   }
}
