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
   @State private var rotateBGMode: Bool = false

   var body: some View {
	  ZStack {
		 // State 1: Only YellowBoxArc rotates with heading
		 // State 2: YellowBoxArc stays fixed
		 YellowBoxArcView(heading: digitalCompassViewModel.headingDegrees)
			.frame(width: 184, height: 184)
			.rotationEffect(.degrees(rotateBGMode ? 0 : digitalCompassViewModel.headingDegrees))

		 // CompassDialView rotates in State 2
		 CompassDialView(heading: digitalCompassViewModel.headingDegrees)
			.frame(width: 184, height: 184)
			.rotationEffect(.degrees(rotateBGMode ? -digitalCompassViewModel.headingDegrees : 0))

		 // State 1: Green arrow rotates with heading
		 // State 2: Green arrow stays fixed
		 ZStack {
			Image("greenArrow")
			   .resizable()
			   .scaledToFit()
			   .frame(width: 50, height: 110)
			   .foregroundColor(.green)
			   .opacity(0.95)
			   .scaleEffect(1.2)

			Text(CardinalDirection.closestDirection(to: digitalCompassViewModel.headingDegrees).rawValue)
			   .font(.subheadline)
			   .foregroundColor(.white)
			   .bold()
			   .shadow(radius: 15)
			   .padding(8)
		 }
		 .rotationEffect(.degrees(rotateBGMode ? 0 : digitalCompassViewModel.headingDegrees))

		 // Center display stays fixed in both states
		 CompassCenterDisplayView(
			headingDegrees: digitalCompassViewModel.headingDegrees,
			cardinal: digitalCompassViewModel.cardinalDirection,
			coordinate: digitalCompassViewModel.coordinate,
			locationName: weatherKitManager.locationName
		 )
	  }
	  .frame(maxWidth: .infinity, maxHeight: .infinity)
	  .background(Color.black)
	  .onTapGesture(count: 2) {
		 withAnimation(.easeInOut(duration: 0.3)) {
			rotateBGMode.toggle()
		 }
	  }
	  .onAppear {
		 digitalCompassViewModel.start()
		 if let coordinate = digitalCompassViewModel.coordinate {
			Task {
			   await weatherKitManager.getWeather(for: coordinate)
			}
		 }
	  }
	  .onDisappear {
		 digitalCompassViewModel.stop()
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
   viewModel.setHeading(90) // East
   return DigitalCompassView(digitalCompassViewModel: viewModel)
}
