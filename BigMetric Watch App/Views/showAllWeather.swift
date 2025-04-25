//
//  showAllWeather.swift
//  howFar Watch App
//
//  Copied from #source1, forklift references from distanceTracker => unifiedWorkoutManager
//  This is displayed in debugScreen or wherever needed
//  No disclaimers, entire code
//

import SwiftUI

struct showAllWeather: View {
   var weatherKitManager: WeatherKitManager
   var geoCodeHelper: GeoCodeHelper
   /// Replaces old distanceTracker => unifiedWorkoutManager
   var unifiedWorkoutManager: UnifiedWorkoutManager

   @State private var address = ""
   private var gradient: Gradient {
	  Gradient(colors: [.gpBlue, .gpRed])
   }

   private let dateFormatter: DateFormatter = {
	  let formatter = DateFormatter()
	  formatter.dateFormat = "M/d"
	  return formatter
   }()

   var body: some View {
	  VStack(spacing: 4) {
		 todaysWeather()
			.onAppear {
			   // Get city name for both local display and weatherKitManager
			   if let lastLoc = unifiedWorkoutManager.lastLocation {
				  geoCodeHelper.getCityNameFromCoordinates(
					 lastLoc.coordinate.latitude,
					 lastLoc.coordinate.longitude
				  ) { placemark in
					 let cityName = placemark?.locality ?? "Weather"
					 address = cityName
					 // Update weatherKitManager's locationName
					 weatherKitManager.locationName = cityName
				  }
			   }
			}
	  }
   }

   func todaysWeather() -> some View {
	  HStack(alignment: .center) {
		 Gauge(
			value: Double(weatherKitManager.tempVar) ?? 0,
			in: (Double(weatherKitManager.lowTempVar) ?? 0)...(Double(weatherKitManager.highTempVar) ?? 0),
			label: { Text("Temp") },
			currentValueLabel: { Text(weatherKitManager.tempVar) },
			markedValueLabels: {}
		 )
		 .gaugeStyle(.accessoryCircular)
		 .tint(gradient)
		 .frame(width: 50, height: 50)
		 .scaleEffect(0.95)
		 .font(.system(size:10))
		 .foregroundColor(.white)
		 .padding(.top, -4)
		 .padding(.bottom, 5)

		 VStack(alignment: .leading, spacing: 2) {
			HStack(alignment: .center, spacing: 2) {
			   let primaryTemp = unifiedWorkoutManager.hotColdFirst
			   ? weatherKitManager.highTempVar
			   : weatherKitManager.lowTempVar
			   let secondTemp = unifiedWorkoutManager.hotColdFirst
			   ? weatherKitManager.lowTempVar
			   : weatherKitManager.highTempVar
			   let fontSize: CGFloat = 16.0

			   Image(systemName: weatherKitManager.symbolVar)
				  .font(.system(size: fontSize))
				  .foregroundColor(.white)

			   Text("\(primaryTemp)°")
				  .font(.system(size: fontSize))
				  .foregroundColor(
					 TemperatureColor.from(temperature: Double(primaryTemp) ?? 0)
				  )

			   Text("/")
				  .font(.system(size: fontSize))
				  .foregroundColor(.white)

			   Text("\(secondTemp)°")
				  .font(.system(size: fontSize))
				  .foregroundColor(
					 TemperatureColor.from(temperature: Double(secondTemp) ?? 0)
				  )
			}

			VStack(alignment: .leading, spacing: 0) {
			   Text(address)
				  .font(.system(size: 12))
				  .foregroundColor(.white)
			   Text(dateFormatter.string(from: Date()))
				  .font(.system(size: 9))
				  .foregroundColor(.gray)
			}
		 }
		 .padding(.leading, 10)
		 Spacer()
	  }
   }
}
