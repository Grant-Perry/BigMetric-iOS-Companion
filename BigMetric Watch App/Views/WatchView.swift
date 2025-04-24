//  WatchView.swift
//  BigMetric Watch App
//
//  Uses animated OrbView/config from ButtonView. Orb is 30% larger.

import SwiftUI
import Orb

struct WatchView: View {
   @State private var currentTime: Date = Date()
   @State private var isLoading = true  // Add loading state
   private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
   private let screenBounds = WKInterfaceDevice.current().screenBounds
   @State private var address = ""
   @State private var locationManager = CLLocationManager()

   let weatherKitManager: WeatherKitManager
   let unifiedWorkoutManager: UnifiedWorkoutManager
   let geoCodeHelper: GeoCodeHelper

   init(weatherKitManager: WeatherKitManager, unifiedWorkoutManager: UnifiedWorkoutManager, geoCodeHelper: GeoCodeHelper) {
	  self.weatherKitManager = weatherKitManager
	  self.unifiedWorkoutManager = unifiedWorkoutManager
	  self.geoCodeHelper = geoCodeHelper
   }

   // Mirror the configuration logic from ButtonView
   var orbConfig: OrbConfiguration {
	  OrbConfiguration(
		 backgroundColors: [.gpBlue, .blue, .gpLtBlue], // easter
		 glowColor: .white,
		 coreGlowIntensity: 1.0, // or 0.25 for "down" state if you wish to add state
		 showWavyBlobs: true,
		 showParticles: true,
		 showGlowEffects: true,
		 showShadow: true,
		 speed: 40
	  )
   }

   private var gradient: Gradient {
	  Gradient(colors: [.gpBlue, .gpRed])
   }

   var weatherView: some View {
	  VStack(spacing: 4) {
		 HStack(alignment: .center, spacing: 4) {
			if weatherKitManager.tempVar.isEmpty {
			   // Show loading animation when no temperature
			   ProgressView()
				  .tint(.white)
				  .scaleEffect(0.7)
			} else {
			   Image(systemName: weatherKitManager.symbolVar)
				  .font(.system(size: 16))
				  .foregroundColor(.white)
				  .id(weatherKitManager.symbolVar)

			   Text("\(weatherKitManager.tempVar)°")
				  .font(.system(size: 16))
				  .foregroundColor(.white)
				  .id(weatherKitManager.tempVar)
			}
		 }
		 .padding(.leading, -20)

		 //MARK: min/max temperature display
		 if !weatherKitManager.lowTempVar.isEmpty && !weatherKitManager.highTempVar.isEmpty {
			HStack(spacing: 2) {
			   Image(systemName: "thermometer")
				  .font(.system(size: 12))
				  .foregroundColor(.white.opacity(0.9))

			   Text("\(weatherKitManager.lowTempVar)°/\(weatherKitManager.highTempVar)°")
				  .font(.system(size: 14))
				  .foregroundColor(.white.opacity(0.9))
			}
			.offset(y: -5)
		 }
	  }
	  .padding(.vertical, 8)
	  .background(Color.black.opacity(0.05))
	  .cornerRadius(30)
	  .offset(x: -30, y: -10)
   }


   var body: some View {
	  // MARK: Orb diameter follows (30% larger)
	  let scale: CGFloat = 1.45 //   xx% larger than before
	  let orbFrameWidth  = (screenBounds.width / 1.5) * 1.03 * scale
	  let orbFrameHeight = (screenBounds.height / 1.5) * 1.03 * scale
	  let orbViewWidth   = (screenBounds.width / 1.35) * 0.85 * scale
	  let orbViewHeight  = (screenBounds.height / 1.5) * 0.95 * scale

	  // MARK: Black Circle Diameter follows (unchanged)
	  let blackWidth = 0.8
	  let blackCircleWidth  = screenBounds.width * blackWidth
	  let blackCircleHeight = screenBounds.height * blackWidth

	  ZStack {
		 VStack(alignment: .leading, spacing: 0) {

			ZStack {
			   Circle()
				  .fill(Color.white)
				  .frame(width: orbFrameWidth, height: orbFrameHeight)
				  .blur(radius: 23)
				  .opacity(0.5)
			}
			.overlay(
			   OrbView(configuration: orbConfig)
				  .aspectRatio(1, contentMode: .fit)
				  .frame(width: orbViewWidth, height: orbViewHeight)
			)
		 }
		 // Black center circle
		 Circle()
			.fill(
			   RadialGradient(gradient: Gradient(colors: [.gpDark, .clear]),
							  center: .center,
							  startRadius: 0,
							  endRadius: blackCircleWidth / 1.65)
			).opacity(0.5)
			.frame(width: blackCircleWidth, height: blackCircleHeight)
			.shadow(color: .black.opacity(0.98), radius: 28, x: 0, y: 0)
			.overlay(
			   VStack(spacing: 0) {
				  // MARK: - Hours:Minutes
				  TimeHMLabel(date: currentTime)
					 .font(.custom("Rajdhani-SemiBold", size: screenBounds.width * 0.45))
					 .foregroundColor(.white)
					 .minimumScaleFactor(0.5)
					 .lineLimit(1)
					 .kerning(-1.5)
					 .scaleEffect(x: 1.2, y: 1.7) // Makes time taller and skinnier
					 .frame(maxWidth: .infinity)
				  TimeSecLabel(date: currentTime)
					 .frame(maxWidth: .infinity)
			   }
				  .frame(width: screenBounds.width * 0.58, height: screenBounds.height * 0.4, alignment: .center)
				  .offset(y: 15)
			)

		 VStack(alignment: .leading) {
			Spacer()
			weatherView
		 }
		 .padding(.bottom, 45)
		 .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
	  }
	  .frame(width: screenBounds.width, height: screenBounds.height, alignment: .center)
	  .background(Color.black.ignoresSafeArea())
	  .onReceive(timer) { currentTime = $0 }
	  .onAppear {
		 // Start weather tracking immediately
		 isLoading = true
		 weatherKitManager.startWeatherTracking()
		 locationManager.requestWhenInUseAuthorization()

		 // Set loading to false after a delay if we get data
		 Task {
			if let lastLoc = unifiedWorkoutManager.lastLocation?.coordinate {
			   await weatherKitManager.getWeather(for: lastLoc)
			} else if let currentLoc = locationManager.location?.coordinate {
			   await weatherKitManager.getWeather(for: currentLoc)
			}
			isLoading = false
		 }
	  }
	  .onDisappear {
		 weatherKitManager.stopWeatherTracking()
	  }
   }
}

// MARK: - Centered hour:minute (no leading zero hour)
struct TimeHMLabel: View {
   let date: Date

   static let formatter: DateFormatter = {
	  let df = DateFormatter()
	  df.dateFormat = "h:mm"
	  return df
   }()

   var body: some View {
	  Text(Self.formatter.string(from: date))
   }
}

// MARK: - Centered seconds label with AM/PM small and raised
struct TimeSecLabel: View {
   let date: Date

   static let secFormatter: DateFormatter = {
	  let df = DateFormatter()
	  df.dateFormat = "ss"
	  return df
   }()
   static let ampmFormatter: DateFormatter = {
	  let df = DateFormatter()
	  df.dateFormat = "a"
	  return df
   }()

   var body: some View {
	  HStack(alignment: .firstTextBaseline, spacing: 2) {
		 // MARK: SECONDS
		 Text(Self.secFormatter.string(from: date))
			.font(.custom("Rajdhani-Light", size: 60))
			.foregroundColor(.white)
			.kerning(-2)
			.lineLimit(1)
			.minimumScaleFactor(0.75)
			.padding(.leading)
		 // MARK: AM/PM
		 Text(Self.ampmFormatter.string(from: date))
			.font(.system(size: 13, weight: .light, design: .rounded))
			.foregroundColor(.white.opacity(0.86))
			.baselineOffset(20)
	  }
	  .frame(maxWidth: .infinity, alignment: .center)
	  .offset(x: 40, y: -16)
   }
}

// MARK: - PREVIEW

// Uncomment if you want a preview in Xcode:

struct WatchView_Previews: PreviewProvider {
   static var previews: some View {
	  WatchView(
		 weatherKitManager: WeatherKitManager(),
		 unifiedWorkoutManager: UnifiedWorkoutManager(),
		 geoCodeHelper: GeoCodeHelper()
	  )
	  .frame(width: 320, height: 320)
	  .previewLayout(.sizeThatFits)
   }
}
