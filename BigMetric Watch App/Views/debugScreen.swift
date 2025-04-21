//
//  debugScreen.swift
//  howFar Watch App
//
//  Reorganized so Weather is at the top, toggles and activity selectors at the bottom.
//  Now updated to have a swoosh .gpDeltaPurple background.
//  Uses showAllWeather + WeatherStatsView with a sheet, same as before.
//  No disclaimers, entire forklift code.
//

import SwiftUI
import CoreLocation
import HealthKit

struct debugScreen: View {
   
   /// The final unified manager
   @State var unifiedWorkoutManager: UnifiedWorkoutManager
   
   /// Weather references
   @State var weatherKitManager: WeatherKitManager
   @State var geoCodeHelper: GeoCodeHelper
   
   @State private var showWeatherStatsView = false
   
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
