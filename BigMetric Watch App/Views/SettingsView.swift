import SwiftUI
import CoreLocation
import HealthKit
import Orb

struct SettingsView: View {
   
   @State var unifiedWorkoutManager: UnifiedWorkoutManager
   @State var weatherKitManager: WeatherKitManager
   @State var geoCodeHelper: GeoCodeHelper
   @State private var showWeatherStatsView = false
   @Environment(MyOrbViewModel.self) private var myOrbViewModel
   
   var body: some View {
	  content
   }
   
   private var content: some View {
	  ZStack {
		 LinearGradient(
			gradient: Gradient(colors: [
			   .purple.opacity(0.8),
			   .blue.opacity(0.6),
			   .purple.opacity(0.3)
			]),
			startPoint: .topLeading,
			endPoint: .bottomTrailing
		 )
		 .ignoresSafeArea()
		 
		 scrollContent
	  }
   }
   
   private var scrollContent: some View {
	  ScrollView {
		 VStack(spacing: 16) {
			settingsSection
			orbColorSection
			activityTypeSection
			versionInfo
			weatherSection
		 }
		 .padding(.vertical)
	  }
   }
   
   private var settingsSection: some View {
	  VStack(alignment: .leading, spacing: 12) {
		 Text("Settings")
			.font(.system(size: 20, weight: .semibold))
			.foregroundColor(.white)
			.padding(.horizontal)
		 
		 VStack(spacing: 8) {
			Toggle("Haptic Feedback", isOn: $unifiedWorkoutManager.isBeep)
			   .toggleStyle(SwitchToggleStyle(tint: .blue))
			Toggle("Precise GPS", isOn: $unifiedWorkoutManager.isPrecise)
			   .toggleStyle(SwitchToggleStyle(tint: .blue))
			Toggle("Walking Trigger", isOn: $unifiedWorkoutManager.isWalkingTriggerOn)
			   .toggleStyle(SwitchToggleStyle(tint: .blue))
		 }
		 .padding()
		 .background(Color.white.opacity(0.15))
		 .cornerRadius(15)
	  }
	  .padding(.horizontal)
   }
   
   private var orbColorSection: some View {
	  VStack(alignment: .leading, spacing: 12) {
		 Text("Customize Orb Colors")
			.font(.system(size: 20, weight: .semibold))
			.foregroundColor(.white)
			.padding(.horizontal)
		 
		 let availableColors: [Color] = [
			.gpWhite, .gpBlue, .gpLtBlue, .gpPurple, .gpRed, .gpPink,
			.gpOrange, .gpRedPink, .gpCoral, .gpDeltaPurple, .gpForest, .gpGreen,
			.gpMinty, .gpBrown, .gpGold, .gpBrightYellow, .gpYellow, .gpBlack
		 ]
		 
		 LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 6), spacing: 6) {
			ForEach(availableColors, id: \.self) { color in
			   Button(action: {
				  myOrbViewModel.updateNextColor(to: color)
			   }) {
				  Rectangle()
					 .fill(color)
					 .frame(width: 20, height: 20)
			   }
			   .buttonStyle(.plain)
			}
		 }
		 .frame(height: 108)
		 
		 // Orb and selection indicators
		 HStack(alignment: .top, spacing: 12) {
			OrbView(configuration: OrbConfiguration(
			   backgroundColors: [
				  myOrbViewModel.orbColor1,
				  myOrbViewModel.orbColor2,
				  myOrbViewModel.orbColor3
			   ],
			   glowColor: .white,
			   coreGlowIntensity: 1.0,
			   showWavyBlobs: true,
			   showParticles: true,
			   showGlowEffects: true,
			   showShadow: true,
			   speed: 40
			))
			.aspectRatio(1, contentMode: .fit)
			.frame(width: 80, height: 80)
			// Disabled long press gesture here
			//			.onLongPressGesture {
			//			   WKInterfaceDevice.current().play(.click)
			//			   myOrbViewModel.saveCurrentToNextFavorite()
			//			}
			
			VStack(spacing: 4) {
			   VStack(spacing: 4) {
				  HStack(spacing: 20) {
					 ForEach([0, 1, 2], id: \.self) { index in
						let color = myOrbViewModel.colorForIndex(index)
						
						Circle()
						   .fill(color)
						   .frame(width: 18, height: 18)
						   .overlay(
							  Circle()
								 .stroke(
									index == myOrbViewModel.colorIndex ? Color.white : Color.clear,
									lineWidth: 2
								 )
						   )
						   .onTapGesture {
							  myOrbViewModel.colorIndex = index
						   }
					 }
				  }
				  
				  HStack(spacing: 8) {
					 Text("Font:")
						.font(.caption2)
						.foregroundColor(.white)
					 
					 Circle()
						.fill(myOrbViewModel.fontColor)
						.frame(width: 18, height: 18)
						.overlay(
						   Circle()
							  .stroke(
								 myOrbViewModel.colorIndex == 3
								 ? (myOrbViewModel.fontColor == .black ? Color.white :
									   myOrbViewModel.fontColor == .white ? Color.black :
									   Color.white)
								 : Color.clear,
								 lineWidth: 2
							  )
						)
						.onTapGesture {
						   myOrbViewModel.colorIndex = 3
						}
				  }
			   }
			}
			
		 }
		 
		 HStack(spacing: 12) {
			ForEach([0, 1, 2], id: \.self) { index in
			   let (top, mid, back, font) = favoriteColors(at: index)
			   let isFilled = top != nil && mid != nil && back != nil && font != nil
			   
			   ZStack {
				  if isFilled {
					 Image(systemName: "star.fill")
						.font(.system(size: 24))
						.foregroundStyle(
						   LinearGradient(colors: [top!, mid!, back!], startPoint: .top, endPoint: .bottom)
						)
				  } else {
					 Image(systemName: "star")
						.font(.system(size: 24))
						.foregroundColor(.white.opacity(0.5))
				  }
			   }
			   .contentShape(Rectangle())
			   .onTapGesture {
				  if isFilled {
					 withAnimation {
						myOrbViewModel.orbColor1 = top!
						myOrbViewModel.orbColor2 = mid!
						myOrbViewModel.orbColor3 = back!
						myOrbViewModel.fontColor = font!
					 }
				  }
			   }
			   .onLongPressGesture {
				  myOrbViewModel.saveToFavorite(at: index)
			   }
			}
			Image(systemName: "arrow.counterclockwise")
			   .font(.system(size: 24))
			   .foregroundColor(.yellow)
			   .onTapGesture {
				  myOrbViewModel.resetToDefaultColors()
			   }
		 }
		 .frame(maxWidth: .infinity, alignment: .center)
		 
	  }
	  .padding(.horizontal)
   }
   
   private func favoriteColors(at index: Int) -> (Color?, Color?, Color?, Color?) {
	  guard let fav = myOrbViewModel.favorites[index] else { return (nil, nil, nil, nil) }
	  return (
		 Color.fromHex(fav.top),
		 Color.fromHex(fav.mid),
		 Color.fromHex(fav.back),
		 Color.fromHex(fav.font)
	  )
   }
   
   private var activityTypeSection: some View {
	  VStack(alignment: .leading, spacing: 12) {
		 Text("Activity Type")
			.font(.system(size: 20, weight: .semibold))
			.foregroundColor(.white)
			.padding(.horizontal)
		 
		 HStack(spacing: 20) {
			ForEach([ActivityTypeSetup.walk, .run, .bike]) { choice in
			   activityTypeButton(choice)
				  .frame(maxWidth: .infinity)
			}
		 }
		 .padding()
		 .background(Color.white.opacity(0.15))
		 .cornerRadius(15)
	  }
	  .padding(.horizontal)
   }
   
   private var versionInfo: some View {
	  Text("\(AppConstants.appName) - ver: \(AppConstants.getVersion())")
		 .font(.system(size: 14, weight: .medium))
		 .foregroundColor(.white.opacity(0.8))
		 .padding(.top, 8)
   }
   
   private var weatherSection: some View {
	  VStack(alignment: .leading, spacing: 12) {
		 Text("Weather")
			.font(.system(size: 20, weight: .semibold))
			.foregroundColor(.white)
			.padding(.horizontal)
		 
		 Text(weatherKitManager.locationName)
			.font(.callout.weight(.medium))
			.foregroundColor(.white)
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(.horizontal)
		 
		 VStack {
			Button(action: {
			   showWeatherStatsView = true
			}) {
			   showAllWeather(
				  weatherKitManager: weatherKitManager,
				  geoCodeHelper: geoCodeHelper,
				  unifiedWorkoutManager: unifiedWorkoutManager
			   )
			   .padding()
			   .background(Color.white.opacity(0.15))
			   .cornerRadius(15)
			}
			.buttonStyle(.plain)
		 }
	  }
	  .padding(.horizontal)
   }
   
   private func activityTypeButton(_ choice: ActivityTypeSetup) -> some View {
	  Button {
		 unifiedWorkoutManager.activityTypeChoice = choice
		 unifiedWorkoutManager.chosenActivityType = choice.hkActivityType
		 unifiedWorkoutManager.maxSpeedMph = choice.maxSpeed
	  } label: {
		 VStack(spacing: 8) {
			Image(systemName: choice.sfSymbol)
			   .font(.system(size: 24, weight: .semibold))
			Text(choice.rawValue.capitalized)
			   .font(.system(size: 12, weight: .medium))
		 }
		 .frame(height: 60)
		 .foregroundColor(
			unifiedWorkoutManager.activityTypeChoice == choice
			? .blue
			: .gray.opacity(0.8)
		 )
	  }
	  .buttonStyle(.plain)
   }
   
   private func logAndPersist(_ message: String) {
	  let timestamp = ISO8601DateFormatter().string(from: Date())
	  let entry = "[\(timestamp)] \(message)"
	  var logs = UserDefaults.standard.stringArray(forKey: "logHistory") ?? []
	  logs.append(entry)
	  UserDefaults.standard.set(Array(logs.suffix(250)), forKey: "logHistory")
#if DEBUG
	  print(message)
#endif
   }
}
