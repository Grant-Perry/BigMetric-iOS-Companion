import SwiftUI
import WeatherKit
import CoreLocation

struct WeatherStatsView: View {

   /// The final managers
   @State var weatherKitManager: WeatherKitManager
   @State var unifiedWorkoutManager: UnifiedWorkoutManager
   @State var geoCodeHelper: GeoCodeHelper

   /// Show/hide this stats view
   @Binding var showWeatherStatsView: Bool

   @State private var address = ""

   /// We reference weatherKitManager for temperature
   var nextHrTemp: Double {
	  Double(weatherKitManager.tempHour) ?? 0
   }
   var thisHrtemp: Double {
	  Double(weatherKitManager.tempVar) ?? 0
   }
   var nextHrTempColor: Color {
	  PrecipChanceColor.from(chance: Int(nextHrTemp))
   }
   var thisHrTempColor: Color {
	  PrecipChanceColor.from(chance: Int(thisHrtemp))
   }
   var precipChance: Double {
	  min(weatherKitManager.precipForecast * 100, 100)
   }
   var precipColor: Color {
	  PrecipChanceColor.from(chance: Int(precipChance))
   }

   var body: some View {
	  ScrollView {
		 VStack {
			// Add city name header at the top
			Text(weatherKitManager.locationName.isEmpty ? "" : weatherKitManager.locationName)
			   .frame(maxWidth: .infinity)
			   .lineLimit(1)
			   .minimumScaleFactor(0.75)
			   .scaledToFit()
			   .foregroundColor(.white)
			   .font(.system(size: 20, weight: .medium))
			   .padding(.vertical, 1)

			// A small close button in top row
			HStack {
			   Button(action: {
				  showWeatherStatsView = false
			   }) {
				  Text("") // just a small area to tap
			   }
			   .font(.system(size: 9))
			   .background(Color.clear)
			   .buttonStyle(PlainButtonStyle())
			   .cornerRadius(5)
			   .padding(.trailing)
			}

			Group {
			   // current temp & conditions
			   Text("\(weatherKitManager.tempVar)°")
				  .font(.system(size: 50, weight: .bold))
				  .foregroundColor(thisHrTempColor)

			   Image(systemName: weatherKitManager.symbolVar)
				  .font(.system(size: 45))
				  .foregroundColor(.white)
			}
			.bold()
			//			Spacer()

			Group {
			   // We unify "hotColdFirst" => ensure we have a property in manager, e.g. var hotColdFirst = false
			   // or if you want a logic, we can do unifiedWorkoutManager.hotColdFirst
			   // We'll assume we have "unifiedWorkoutManager.hotColdFirst" (Bool)
			   let showHigh = unifiedWorkoutManager.hotColdFirst ? weatherKitManager.highTempVar : weatherKitManager.lowTempVar
			   let showLow  = unifiedWorkoutManager.hotColdFirst ? weatherKitManager.lowTempVar : weatherKitManager.highTempVar

			   let fontSize: CGFloat = 13

			   HStack {
				  Text("\(showHigh)°")
					 .foregroundColor(
						TemperatureColor.from(
						   temperature: Double(showHigh) ?? 0
						)
					 )
				  Text(" / ")
					 .foregroundColor(.white)
				  Text("\(showLow)°")
					 .foregroundColor(
						TemperatureColor.from(
						   temperature: Double(showLow) ?? 0
						)
					 )
			   }
			   .font(.system(size: fontSize))

			   // Symbol for next hour
			   Image(systemName: weatherKitManager.symbolHourly)
			   HStack {
				  Text("Next Hr Rain:")
					 .foregroundColor(.white)
				  Text("\(gpNumFormat.formatNumber(precipChance, 0))%")
					 .foregroundColor(precipColor)
			   }
			   HStack {
				  Text("Next Hr Temp:")
					 .foregroundColor(.white)

				  Text(gpNumFormat.formatNumber(nextHrTemp, 0))
					 .foregroundColor(nextHrTempColor)
			   }
			}
			.font(.system(size: 12))
		 }

		 // Show address
		 Text(address)
			.onAppear {
			   if let lastLoc = unifiedWorkoutManager.lastLocation {
				  geoCodeHelper.getCityNameFromCoordinates(
					 lastLoc.coordinate.latitude,
					 lastLoc.coordinate.longitude
				  ) { placemark in
					 address = placemark?.locality ?? "loading"
				  }
			   }
			}
			.font(.footnote)
			.foregroundColor(.gpPurple)
			.bold()

		 Divider().padding(.vertical)

		 // daily forecast
		 VStack(alignment: .leading, spacing: 10) {
			ForEach(Array(weatherKitManager.weekForecast.enumerated()), id: \.element.id) { index, forecast in
			   dailyView(index, forecast)
			   Divider()
			}
		 }
	  }
   }

   private func dailyView(_ index: Int, _ forecast: WeatherKitManager.Forecasts) -> some View {
	  HStack {
		 Group {
			VStack(alignment: .leading, spacing: 2) {
			   Text("\(gpDateStuff.getDayName(daysFromToday: index + 1)):")
				  .font(.system(size: 20))
				  .bold()
				  .foregroundColor(.white)

			   // Add the date under the day name
			   if let date = Calendar.current.date(byAdding: .day, value: index + 1, to: Date()) {
				  Text(date.formatted(.dateTime.month(.defaultDigits)).appending("/")
					   + date.formatted(.dateTime.day(.defaultDigits)))
				  .font(.system(size: 12))
				  .foregroundColor(.gray)
			   }
			}
			Spacer()
			Image(systemName: forecast.symbolName)
			   .foregroundColor(.white)
			   .bold()
		 }

		 Spacer()
		 let mainTemp = unifiedWorkoutManager.hotColdFirst ? forecast.maxTemp : forecast.minTemp
		 let secondTemp = unifiedWorkoutManager.hotColdFirst ? forecast.minTemp : forecast.maxTemp
		 let mainColor = TemperatureColor.from(temperature: Double(mainTemp) ?? 0)
		 let secondColor = TemperatureColor.from(temperature: Double(secondTemp) ?? 0)

		 HStack {
			Text("\(unifiedWorkoutManager.hotColdFirst ? mainTemp : secondTemp)°")
			   .foregroundColor(
				  unifiedWorkoutManager.hotColdFirst ? mainColor : secondColor
			   )
			   .font(.system(size: 17))
			Text("/")
			   .foregroundColor(.white)
			Text("\(unifiedWorkoutManager.hotColdFirst ? secondTemp : mainTemp)°")
			   .foregroundColor(
				  unifiedWorkoutManager.hotColdFirst ? secondColor : mainColor
			   )
			   .font(.system(size: 17))
		 }
		 .font(.system(size: 20))
		 .bold()
	  }
   }
}
