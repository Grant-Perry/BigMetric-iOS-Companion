//
//  DigitalCompassView.swift
//  BigMetric Watch App
//
//  Created by Gp. on 2025-04-22.

import SwiftUI

/// A full-screen compass interface that mimics the Apple Watch Compass style.
/// This view uses modular subviews for dial, pointer, and display overlays.
struct DigitalCompassView: View {
   @State var digitalCompassViewModel: DigitalCompassViewModel
   @StateObject private var weatherKitManager = WeatherKitManager()
   @StateObject private var altitudeManager = AltitudeManager()
   @State private var rotateBGMode: Bool = false

   private var isNearCardinal: Bool {
	  let heading = digitalCompassViewModel.headingDegrees.truncatingRemainder(dividingBy: 360)
	  let cardinalPoints = [0, 90, 180, 270]
	  return cardinalPoints.contains { abs(heading - Double($0)).truncatingRemainder(dividingBy: 360) <= 5 }
   }

   var body: some View {
	  ZStack {
		 YellowBoxArcView(heading: digitalCompassViewModel.headingDegrees, rotateBGMode: rotateBGMode)
			.frame(width: 184, height: 184)

		 CompassDialView(heading: digitalCompassViewModel.headingDegrees)
			.frame(width: 184, height: 184)
			.rotationEffect(.degrees(rotateBGMode ? -digitalCompassViewModel.headingDegrees : 0))

		 ZStack {
			Image("greenArrow")
			   .resizable()
			   .scaledToFit()
			   .frame(width: 110, height: 110)
			   .foregroundColor(.green)
			   .opacity(0.95)
			   .scaleEffect(1.05)
			   .shadow(color: .gpDark, radius: 10)

			Text(CardinalDirection.closestDirection(to: digitalCompassViewModel.headingDegrees).rawValue)
			   .font(.custom("Rajdhani-Regular", size:30))
			   .foregroundColor(.white)
			   .bold()
			   .shadow(radius: 5)
			   .padding(8)
		 }
		 .rotationEffect(.degrees(rotateBGMode ? 0 : digitalCompassViewModel.headingDegrees))

		 VStack {
			Spacer()
			VStack(spacing: 2) {
			   HStack {
				  Image("Altitude")
					 .font(.system(.caption))
					 .foregroundColor(.white)
				  Spacer()
				  Image(systemName: "safari")
					 .font(.system(.caption))
					 .foregroundColor(.white)
			   }
			   HStack {
				  Text(altitudeManager.altitudeString)
					 .font(.system(.title3, design: .monospaced))
					 .foregroundColor(.white)
				  Spacer()
				  Text(String(format: "%.0f°", digitalCompassViewModel.headingDegrees))
					 .font(.system(.title3, design: .monospaced))
					 .foregroundColor(.white)
			   }
			}
			.padding(.horizontal)
			.offset(y: 13)
		 }
	  }
	  .frame(maxWidth: .infinity, maxHeight: .infinity)
	  .background(Color.black)
	  .onTapGesture(count: 2) {
		 rotateBGMode.toggle()
	  }
	  .onAppear {
		 digitalCompassViewModel.start()
		 altitudeManager.startUpdates()
		 if let coordinate = digitalCompassViewModel.coordinate {
			Task {
			   await weatherKitManager.getWeather(for: coordinate)
			}
		 }
	  }
	  .onDisappear {
		 digitalCompassViewModel.stop()
		 altitudeManager.stopUpdates()
	  }
	  .onChange(of: digitalCompassViewModel.coordinate?.latitude) { _, _ in
		 if let coordinate = digitalCompassViewModel.coordinate {
			Task {
			   await weatherKitManager.getWeather(for: coordinate)
			}
		 }
	  }
	  .onChange(of: digitalCompassViewModel.coordinate?.longitude) { _, _ in
		 if let coordinate = digitalCompassViewModel.coordinate {
			Task {
			   await weatherKitManager.getWeather(for: coordinate)
			}
		 }
	  }
   }
}

#Preview("East") {
   let viewModel = DigitalCompassViewModel.preview
   viewModel.setHeading(270) // East
   return DigitalCompassView(digitalCompassViewModel: viewModel)
}
