import SwiftUI
import CoreLocation

struct CompassView: View {
   @State var screenBounds = WKInterfaceDevice.current().screenBounds
   @StateObject private var compassManager = CompassLMManager()
   @State private var rotateBGMode: Bool = false

   var body: some View {
	  Group {
		 if !compassManager.isCompassAvailable {
			Text("Compass not available")
			   .foregroundColor(.white)
		 } else if compassManager.isCalibrating {
			Text("Calibrating compass...")
			   .foregroundColor(.white)
		 } else if compassManager.compassError != nil {
			Text("Compass Error\nTry moving away from interference")
			   .foregroundColor(.white)
			   .multilineTextAlignment(.center)
		 } else {
			ZStack {
			   Image("CompassBG")
				  .resizable()
				  .scaledToFit()
				  .frame(width: screenBounds.width, height: screenBounds.width)
				  .opacity(0.8)
				  .rotationEffect(.degrees(rotateBGMode ? -compassManager.course : 0))
				  .animation(.spring(response: 0.5), value: rotateBGMode)

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
		 //		 logAndPersist("[CompassView] appearing - starting updates")
		 compassManager.startUpdates()
	  }
	  .onDisappear {
		 //		 logAndPersist("[CompassView] disappearing - stopping updates")
		 compassManager.stopUpdates()
	  }
   }

   //   private func logAndPersist(_ message: String) {
   //	  let timestamp = ISO8601DateFormatter().string(from: Date())
   //	  let entry = "[\(timestamp)] \(message)"
   //	  var logs = UserDefaults.standard.stringArray(forKey: "logHistory") ?? []
   //	  logs.append(entry)
   //	  UserDefaults.standard.set(Array(logs.suffix(250)), forKey: "logHistory")
   //#if DEBUG
   //	  print(message)
   //#endif
   //   }
}

#Preview {
   CompassView()
	  .frame(width: WKInterfaceDevice.current().screenBounds.width)
	  .background(Color.black)
}
