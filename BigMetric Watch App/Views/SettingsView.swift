import SwiftUI
import CoreLocation
import HealthKit
import Orb

struct SettingsView: View {
   
   /// The final unified manager
   @State var unifiedWorkoutManager: UnifiedWorkoutManager
   
   /// Weather references
   @State var weatherKitManager: WeatherKitManager
   @State var geoCodeHelper: GeoCodeHelper
   
   @State private var showWeatherStatsView = false
   
   @Environment(MyOrbViewModel.self) private var myOrbViewModel
   
   var body: some View {
	  ZStack {
		 /// The gpDeltaPurple gradient swoosh background
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
		 
		 /// The main form content
		 ScrollView {
			VStack(spacing: 16) {
			   // CHANGE: Add frame and alignment for city name
			   Text(weatherKitManager.locationName)
				  .font(.callout.weight(.medium))
				  .foregroundColor(.white)
				  .padding(.top)
				  .frame(maxWidth: .infinity, alignment: .leading)
				  .padding(.horizontal)
			   
			   // Weather Section with modern card design
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
			   .padding(.horizontal)
			   
			   // Debug Toggles with modern switch styling
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
			   
			   // Orb Color Picker Section
			   VStack(alignment: .leading, spacing: 12) {
				  Text("Customize Orb Colors")
					 .font(.system(size: 20, weight: .semibold))
					 .foregroundColor(.white)
					 .padding(.horizontal)
				  
				  // Color swatch grid - updated to show all 18 colors in a 6x3 layout with padding
				  let availableColors: [Color] = [
					 .gpWhite,
					 .gpBlue,
					 .gpLtBlue,
					 .gpPurple,
					 .gpRed,
					 .gpPink,
					 .gpOrange,
					 .gpRedPink,
					 .gpCoral,
					 .gpDeltaPurple,
					 .gpForest,
					 .gpGreen,
					 .gpMinty,
					 .gpBrown,
					 .gpGold,
					 .gpBrightYellow,
					 .gpYellow,
					 .gpBlack
				  ]
				  // Updated: Explicit 6 columns, fixed height for 3 full rows
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
					 
					 VStack(alignment: .leading, spacing: 6) {
						ForEach(0..<4, id: \.self) { index in
						   Button(action: {
							  myOrbViewModel.colorIndex = index
						   }) {
							  HStack(alignment: .center, spacing: 8) {
								 let label = ["Top", "Mid", "Back", "Font"][index]
								 let color: Color = {
									switch index {
									   case 0: return myOrbViewModel.orbColor1
									   case 1: return myOrbViewModel.orbColor2
									   case 2: return myOrbViewModel.orbColor3
									   case 3: return myOrbViewModel.fontColor
									   default: return .clear
									}
								 }()
								 
								 HStack(spacing: 0) {
									Text(label)
									   .font(.caption2)
									   .foregroundColor(.white)
									   .frame(width: 36, alignment: .trailing)
									Text(":")
									   .font(.caption2)
									   .foregroundColor(.white)
								 }
								 
								 Rectangle()
									.fill(color)
									.frame(width: 18, height: 18)
									.overlay(
									   RoundedRectangle(cornerRadius: 3)
										  .stroke(index == myOrbViewModel.colorIndex ? Color.white : Color.clear, lineWidth: 2)
									)
							  }
						   }
						   .buttonStyle(.plain)
						}
					 }
				  }
				  
				  Button("Reset to Default Colors") {
					 myOrbViewModel.resetToDefaultColors()
				  }
				  .buttonStyle(.borderedProminent)
				  .tint(.yellow)
				  .padding(.horizontal)
			   }
			   .padding(.horizontal)
			   
			   // Activity Type with modern icon buttons
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
			   
			   // Version info with modern styling
			   Text("\(AppConstants.appName) - ver: \(AppConstants.getVersion())")
				  .font(.system(size: 14, weight: .medium))
				  .foregroundColor(.white.opacity(0.8))
				  .padding(.top, 8)
			}
			.padding(.vertical)
		 }
		 .sheet(isPresented: $showWeatherStatsView) {
			WeatherStatsView(
			   weatherKitManager: weatherKitManager,
			   unifiedWorkoutManager: unifiedWorkoutManager,
			   geoCodeHelper: geoCodeHelper,
			   showWeatherStatsView: $showWeatherStatsView
			)
		 }
		 .navigationTitle("Debug Screen")
		 .navigationBarTitleDisplayMode(.inline)
		 .onAppear {
			logAndPersist("[DebugScreen] onAppear => weIsRecording: \(unifiedWorkoutManager.weIsRecording)")
			
			if unifiedWorkoutManager.weIsRecording,
			   let location = unifiedWorkoutManager.LMDelegate.location,
			   location.horizontalAccuracy <= 50.0
			{
			Task {
			   await weatherKitManager.getWeather(for: location.coordinate)
			   unifiedWorkoutManager.updateWeatherInfo(from: weatherKitManager)
			}
			}
		 }
	  }
   }
   
   /// The row of SF Symbol buttons for .walk, .run, .bike
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
