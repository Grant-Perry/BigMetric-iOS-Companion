//
//  CompassView.swift
//  BigMetric Watch App
//
//  Fully SwiftUI–drawn modern compass with live data quadrants.
//  Bottom‑right quadrant displays elevation in feet with icon.

import SwiftUI
import CoreLocation

struct CompassView: View {
   // MARK: – Managers
   @StateObject private var compassManager: CompassLMManager
   @StateObject private var workoutManager: UnifiedWorkoutManager

   // MARK: – State
   @State private var fixedArrowMode: Bool = false

   // MARK: – Layout Constants
   private let ringLineWidth: CGFloat         = 8
   private let tickMajorWidth: CGFloat        = 3
   private let tickMinorWidth: CGFloat        = 1.5
   private let tickMajorHeightRatio: CGFloat  = 0.12
   private let tickMinorHeightRatio: CGFloat  = 0.06
   private let cardinalCircleDiameter: CGFloat = 38

   // MARK: – Initializer
   init(
	  compassManager: CompassLMManager = CompassLMManager(),
	  workoutManager: UnifiedWorkoutManager = UnifiedWorkoutManager()
   ) {
	  _compassManager = StateObject(wrappedValue: compassManager)
	  _workoutManager = StateObject(wrappedValue: workoutManager)
   }

   // MARK: – Computed Helpers
   private var compassSize: CGFloat {
	  min(WKInterfaceDevice.current().screenBounds.width,
		  WKInterfaceDevice.current().screenBounds.height)
   }
   private var latText: String {
	  let lat = workoutManager.lastLocation?.coordinate.latitude ?? 0
	  return String(format: "%.4f° N", lat)
   }
   private var lonText: String {
	  let lon = workoutManager.lastLocation?.coordinate.longitude ?? 0
	  return String(format: "%.4f° E", lon)
   }
   private var elevationFeet: Int {
	  let meters = workoutManager.lastLocation?.altitude ?? 0.0
	  return Int(meters * 3.28084)
   }

   var body: some View {
	  GeometryReader { geo in
		 let size    = min(geo.size.width, geo.size.height)
		 let radius  = size / 2
		 let heading = compassManager.course.truncatingRemainder(dividingBy: 360)
		 let activeCardinal = CardinalDirection.from(degrees: heading)
		 let dialRotation = fixedArrowMode ? -heading : 0
		 let arrowRotation = fixedArrowMode ? -heading - 180 : heading

		 ZStack {
			// 1. Outer Ring & Ticks
			ringAndTicks(size: size, radius: radius)
			   .rotationEffect(.degrees(dialRotation))

			// 2. Quadrant Circle (replace crosshair)
			Circle()
			   .fill(Color.gpLtBlue)
			   .frame(width: radius * 1.75, height: radius * 1.75)
			   .opacity(0.2)

			// 3. Cardinal Circles (ride dial, stay upright)
			cardinalCircles(radius: radius,
							active: activeCardinal,
							dialRotation: dialRotation)

			// 4. Green Semi‑Circular Arc centered on heading
			Circle()
			   .trim(from: 0, to: 0.5)
			   .stroke(Color.green,
					   style: StrokeStyle(lineWidth: 6, lineCap: .round))
			   .frame(width: size * 0.96, height: size * 0.96)
			   .rotationEffect(.degrees(heading - 90))
			   .rotationEffect(.degrees(dialRotation))

			// 5. Central Arrow + Cardinal initial
			ZStack {
			   Image("greenArrow")
				  .resizable()
				  .scaledToFit()
				  .frame(width: 40, height: 80)
				  .scaleEffect(1.5)
				  .rotationEffect(.degrees(arrowRotation))
				  .rotationEffect(.degrees(dialRotation))
				  .opacity(0.95)
				  .shadow(color: Color.green.opacity(0.6), radius: 4)

			   Text(activeCardinal.rawValue)
				  .font(.system(size: 20, weight: .bold))
				  .foregroundColor(.white)
				  .shadow(color: Color.black.opacity(0.8), radius: 4, x: 1, y: 1)
			}

			// 6. Blue Accent Halos
			blueHalos(size: size, rotation: dialRotation)

			// 7. Data Quadrants
			dataQuadrants(radius: radius,
						  heading: heading,
						  activeCardinal: activeCardinal,
						  dialRotation: dialRotation)
		 }
		 .frame(width: size, height: size)
		 .contentShape(Rectangle())
		 .onTapGesture(count: 2) {
			withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
			   fixedArrowMode.toggle()
			}
		 }
		 .onAppear {
#if !DEBUG
			compassManager.startUpdates()
			workoutManager.weatherKitManager.startWeatherTracking()
			Task { await workoutManager.fetchWeatherAndCityIfNeeded() }
#endif
		 }
		 .onDisappear {
#if !DEBUG
			compassManager.stopUpdates()
			workoutManager.weatherKitManager.stopWeatherTracking()
#endif
		 }
	  }
	  .frame(width: compassSize, height: compassSize)
	  .background(Color.black.edgesIgnoringSafeArea(.all))
   }
}

private extension CompassView {
   @ViewBuilder
   func ringAndTicks(size: CGFloat, radius: CGFloat) -> some View {
	  Circle()
		 .stroke(
			AngularGradient(
			   gradient: Gradient(colors: [
				  Color.blue.opacity(0.8),
				  Color.cyan.opacity(0.6),
				  Color.blue.opacity(0.8)
			   ]), center: .center),
			lineWidth: ringLineWidth)
		 .shadow(color: Color.blue.opacity(0.4), radius: 4)
		 .frame(width: size, height: size)

	  ForEach(0..<60, id: \.self) { i in
		 let angle = Double(i) * 6
		 let isMajor = i % 5 == 0
		 Capsule()
			.fill(isMajor ? Color.white : Color.white.opacity(0.4))
			.frame(
			   width:  isMajor ? tickMajorWidth : tickMinorWidth,
			   height: isMajor ? radius * tickMajorHeightRatio : radius * tickMinorHeightRatio
			)
			.offset(y: -radius + ((isMajor ? radius * tickMajorHeightRatio/2 : radius * tickMinorHeightRatio/2)))
			.rotationEffect(.degrees(angle))
	  }
   }

   @ViewBuilder
   func cardinalCircles(radius: CGFloat, active: CardinalDirection, dialRotation: Double) -> some View {
	  ForEach(CardinalDirection.allPrimary, id: \.self) { dir in
		 Group {
			ZStack {
			   Circle()
				  .stroke(Color.gpLtBlue.opacity(0.25), lineWidth: 10)
				  .frame(width: cardinalCircleDiameter, height: cardinalCircleDiameter)

			   Circle()
				  .fill(Color.gpBlue).opacity(0.54)
				  .frame(width: cardinalCircleDiameter, height: cardinalCircleDiameter)
				  .overlay(
					 Circle()
						.stroke(
						   dir == active ? Color.blue : Color.white.opacity(0.85),
						   lineWidth: dir == active ? 3 : 2.2
						)
				  )

			   Text(dir.rawValue)
				  .font(.system(size: 24, weight: .semibold))
				  .foregroundColor(dir == active ? .white : .white.opacity(0.93))
				  .rotationEffect(.degrees(-dir.angle))
			}
			.offset(y: -radius + 16)
			.rotationEffect(.degrees(dir.angle))
		 }
		 .rotationEffect(.degrees(dialRotation))
	  }
   }

   @ViewBuilder
   func blueHalos(size: CGFloat, rotation: Double) -> some View {
	  Circle()
		 .trim(from: 0.14, to: 0.22)
		 .stroke(
			AngularGradient(
			   gradient: Gradient(colors: [Color.cyan.opacity(0.7), Color.blue.opacity(0.7)]),
			   center: .center
			), lineWidth: 4)
		 .frame(width: size * 0.8, height: size * 0.8)
		 .rotationEffect(.degrees(rotation))
	  Circle()
		 .trim(from: 0.61, to: 0.69)
		 .stroke(
			AngularGradient(
			   gradient: Gradient(colors: [Color.cyan.opacity(0.7), Color.blue.opacity(0.7)]),
			   center: .center
			), lineWidth: 4)
		 .frame(width: size * 0.8, height: size * 0.8)
		 .rotationEffect(.degrees(rotation))
   }

   @ViewBuilder
   func dataQuadrants(radius: CGFloat, heading: Double, activeCardinal: CardinalDirection, dialRotation: Double) -> some View {
	  let offset = radius * 0.39

	  VStack(alignment: .center, spacing: 2) {
		 Text(latText)
			.font(.system(size: 10, design: .monospaced))
		 Text(lonText)
			.font(.system(size: 10, design: .monospaced))
		 Text(workoutManager.locationName)
			.font(.system(size: 12, weight: .semibold))
			.foregroundColor(.white.opacity(0.85))
	  }
	  .offset(x: -offset, y: -offset)

	  VStack(spacing: 2) {
		 Text("\(Int(round(heading)))°")
			.font(.title2).bold()
			.foregroundColor(.white)
		 Text(activeCardinal.fullName)
			.font(.system(size: 10, weight: .semibold))
			.foregroundColor(.white.opacity(0.9))
	  }
	  .offset(x: offset, y: -offset)

	  HStack(spacing: 6) {
		 Image(systemName: workoutManager.weatherKitManager.symbolVar)
			.font(.system(size: 20))
			.offset(x: 4, y: -11)
		 //			.foregroundColor(.yellow)
		 Text(workoutManager.weatherKitManager.tempVar)
			.font(.title2)
			.foregroundColor(.white)
			.offset(x: -8, y: 9)
	  }
	  .offset(x: -offset, y: offset)

	  HStack(spacing: 4) {
		 Image(systemName: "mountain.2")
			.font(.system(size: 14))
			.foregroundColor(.white)
			.offset(x: 28, y: -20)

		 Text("\(elevationFeet.formatted(.number.grouping(.automatic)))")
		 //			.frame(maxWidth: .infinity)
			.lineLimit(1)
			.minimumScaleFactor(0.5)
			.scaledToFit()

			.font(.title2)
			.foregroundColor(.white)
			.offset(x: 5, y: 9)
		 Text(" ft")


	  }
	  .offset(x: offset, y: offset)
   }
}

#if DEBUG
struct CompassView_Previews: PreviewProvider {
   static var previews: some View {
	  let mockCompass = CompassLMManager()
	  mockCompass.course = 90
	  let mockWorkout = UnifiedWorkoutManager()
	  mockWorkout.lastLocation = CLLocation(latitude: 48.8566, longitude: 2.3522)
	  mockWorkout.locationName = "Paris, FR"
	  mockWorkout.weatherKitManager.symbolVar = "cloud.sun.fill"
	  mockWorkout.weatherKitManager.tempVar = "72°F"
	  return CompassView(compassManager: mockCompass,
						 workoutManager: mockWorkout)
	  .frame(width: 200, height: 200)
	  .background(Color.black)
   }
}
#endif
