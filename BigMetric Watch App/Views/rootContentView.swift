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
			unifiedWorkoutManager: unifiedWorkoutManager
		 )
		 .tabItem { Image(systemName: "circle.fill") }
		 .tag(5)

		 AltitudeView(unifiedWorkoutManager: unifiedWorkoutManager)
			.tabItem { Image(systemName: "circle.fill") }
			.tag(6)
	  }
	  .onAppear {
		 unifiedWorkoutManager.onEndAndShowSummary = {
			self.selectedTab = 4
		 }

		 unifiedWorkoutManager.requestHKAuth()
		 selectedTab = 2
	  }
	  .tabViewStyle(PageTabViewStyle())
   }
}
