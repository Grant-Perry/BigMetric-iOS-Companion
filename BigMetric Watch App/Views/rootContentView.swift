import SwiftUI

struct RootBigMetricView: View {
   @ObservedObject var unifiedWorkoutManager: UnifiedWorkoutManager
   @ObservedObject var weatherKitManager: WeatherKitManager
   @State var geoCodeHelper: GeoCodeHelper

   @Binding var selectedTab: Int

   var body: some View {
	  TabView(selection: $selectedTab) {
		 endWorkout(
			unifiedWorkoutManager: unifiedWorkoutManager,
			selectedTab: $selectedTab
		 )
		 .tabItem { Image(systemName: "circle.fill") }
		 .tag(0)

		 howFarGPS(
			unifiedWorkoutManager: unifiedWorkoutManager
		 )
		 .tabItem { Image(systemName: "circle.fill") }
		 .tag(2)

		 debugScreen(
			unifiedWorkoutManager: unifiedWorkoutManager,
			weatherKitManager: weatherKitManager,
			geoCodeHelper: geoCodeHelper
		 )
		 .tabItem { Image(systemName: "circle.fill") }
		 .tag(3)

		 summary(
			unifiedWorkoutManager: unifiedWorkoutManager,
			weatherKitManager: weatherKitManager,
			selectedTab: $selectedTab
		 )
		 .tabItem { Image(systemName: "circle.fill") }
		 .tag(4)

		 CompassView(
			unifiedWorkoutManager: unifiedWorkoutManager,
			heading: unifiedWorkoutManager.course,
			routeHeading: unifiedWorkoutManager.course
		 )
		 .tabItem { Image(systemName: "circle.fill") }
		 .tag(5)


		 AltitudeView(unifiedWorkoutManager: unifiedWorkoutManager)
			.tabItem { Image(systemName: "circle.fill") }
			.tag(6)

		 // ... etc. for other tabs
	  }
	  .onAppear {
		 // Now it's safe to reference self in a closure.
		 // The entire RootContentView is fully initialized.
		 unifiedWorkoutManager.onEndAndShowSummary = {
			// Move to tab #4 (the summary)
			self.selectedTab = 4
		 }

		 // Optionally do HK auth here:
		 unifiedWorkoutManager.requestHKAuth()

		 // Start on tab #2
		 selectedTab = 2
	  }
	  .tabViewStyle(PageTabViewStyle())
   }
}
