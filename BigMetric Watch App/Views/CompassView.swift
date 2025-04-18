import SwiftUI
import CoreLocation

struct CompassView: View {
   @State var screenBounds = WKInterfaceDevice.current().screenBounds
   @StateObject private var compassManager = CompassLMManager()
   @State private var rotateBGMode: Bool = false
   @State private var bgRotation: Double = 0
   @State private var arrowRotation: Double = 0

   var body: some View {
	  ZStack {
		 Image("CompassBG")
			.resizable()
			.scaledToFit()
			.frame(width: screenBounds.width * 0.9, height: screenBounds.width * 0.9)
			.rotationEffect(.degrees(rotateBGMode ? -compassManager.course : 0))
			.animation(.spring(response: 0.5), value: rotateBGMode)

		 Circle()
			.stroke(Color.white.opacity(0.5), lineWidth: 4)
			.frame(width: screenBounds.width * 0.95, height: screenBounds.width * 0.95)

		 Circle()
			.trim(from: 0.125, to: 0.375)
			.stroke(Color.green.opacity(0.7), lineWidth: 6)
			.frame(width: screenBounds.width * 0.95, height: screenBounds.width * 0.95)
			.rotationEffect(.degrees(compassManager.course - 180))

		 Image("greenArrow")
			.resizable()
			.scaledToFit()
			.frame(width: 50, height: 110)
			.foregroundColor(.green)
			.rotationEffect(.degrees(rotateBGMode ? 0 : compassManager.course))
			.opacity(0.95)
			.scaleEffect(1.2)
			.animation(.spring(response: 0.5), value: rotateBGMode)

		 Text(compassManager.heading)
			.font(.title3)
			.foregroundColor(.white)
			.bold()
			.shadow(radius: 15)
			.padding(8)
			.background(Circle().fill(Color.black.opacity(0.25)))

		 VStack {
			Spacer()
			HStack {
			   Text("\(Int(compassManager.course))°")
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
		 compassManager.startUpdates()
	  }
	  .onDisappear {
		 compassManager.stopUpdates()
	  }
   }
}

#Preview {
   CompassView()
	  .frame(width: WKInterfaceDevice.current().screenBounds.width)
	  .background(Color.black)
}
