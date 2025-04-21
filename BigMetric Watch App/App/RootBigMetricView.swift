// At the top, add import if not present:
import SwiftUI

// At the bottom of the TabView, add the DebugLogView as last .tabItem:

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

		 CompassView()
			.tabItem { Image(systemName: "circle.fill") }
			.tag(5)

		 showHeartBeat(
			unifiedWorkoutManager: unifiedWorkoutManager
		 )
		 .tabItem { Image(systemName: "circle.fill") }
		 .tag(6)

		 AltitudeView(unifiedWorkoutManager: unifiedWorkoutManager)
			.tabItem { Image(systemName: "circle.fill") }
			.tag(7)

		 // ADD: DebugLogView as the last tab
		 DebugLogView()
			.tabItem { Image(systemName: "doc.text.magnifyingglass") }
			.tag(8)
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
