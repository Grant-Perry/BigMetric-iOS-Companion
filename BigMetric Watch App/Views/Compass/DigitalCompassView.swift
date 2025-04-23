//
//  DigitalCompassView.swift
//  BigMetric Watch App
//
//  Created by Gp. on 2025-04-22.

import SwiftUI
//import Cardinal

/// A full-screen compass interface that mimics the Apple Watch Compass style.
/// This view uses modular subviews for dial, pointer, and display overlays.
struct DigitalCompassView: View {
   @State var digitalCompassViewModel: DigitalCompassViewModel
   @StateObject private var weatherKitManager = WeatherKitManager()

   var body: some View {
	  ZStack {
		 // YellowBoxArcView as container
		 YellowBoxArcView(heading: digitalCompassViewModel.headingDegrees)
			.frame(width: 184, height: 184)

		 // CompassDialView centered inside
		 CompassDialView(heading: digitalCompassViewModel.headingDegrees)
			.frame(width: 184, height: 184)

		 // Center degrees and cardinal + coordinates
		 CompassCenterDisplayView(
			headingDegrees: digitalCompassViewModel.headingDegrees,
			cardinal: digitalCompassViewModel.cardinalDirection,
			coordinate: digitalCompassViewModel.coordinate,
			locationName: weatherKitManager.locationName
		 )

		 // North pointer on top
		 NorthPointerView()
	  }
	  .frame(maxWidth: .infinity, maxHeight: .infinity)
	  .background(Color.black)
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

//#Preview("North") {
//   let viewModel = DigitalCompassViewModel.preview
//   viewModel.setHeading(0) // North
//   return DigitalCompassView(digitalCompassViewModel: viewModel)
//}
//
//#Preview("Northeast") {
//   let viewModel = DigitalCompassViewModel.preview
//   viewModel.setHeading(45) // Northeast
//   return DigitalCompassView(digitalCompassViewModel: viewModel)
//}

#Preview("East") {
   let viewModel = DigitalCompassViewModel.preview
   viewModel.setHeading(90) // East
   return DigitalCompassView(digitalCompassViewModel: viewModel)
}
