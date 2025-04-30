import SwiftUI
import UserNotifications

@main
struct BigMetric_Watch_AppApp: App {
   @State private var unifiedWorkoutManager: UnifiedWorkoutManager
   @State private var weatherKitManager: WeatherKitManager
   @State private var geoCodeHelper: GeoCodeHelper
   @State private var selectedTab = 2
   @State private var myOrbViewModel = MyOrbViewModel()
   
   // Explicitly hold a strong reference to the delegate
   private let notificationDelegate: NotificationDelegate
   
   init() {
	  let manager = UnifiedWorkoutManager()
	  self._unifiedWorkoutManager = State(initialValue: manager)
	  self._weatherKitManager = State(initialValue: WeatherKitManager(unifiedWorkoutManager: manager))
	  self._geoCodeHelper = State(initialValue: GeoCodeHelper())
	  
	  manager.startMonitoringActivity()
	  
	  // Instantiate and hold strongly in memory explicitly
	  self.notificationDelegate = NotificationDelegate(workoutManager: manager)
	  UNUserNotificationCenter.current().delegate = notificationDelegate
	  
	  UNUserNotificationCenter.current().getNotificationSettings { settings in
		 if settings.authorizationStatus == .notDetermined {
			UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
		 }
	  }
   }
   
   var body: some Scene {
	  WindowGroup {
		 RootBigMetricView(
			unifiedWorkoutManager: unifiedWorkoutManager,
			weatherKitManager: weatherKitManager,
			geoCodeHelper: geoCodeHelper,
			selectedTab: $selectedTab
		 )
		 .environment(myOrbViewModel)
	  }
   }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
   var workoutManager: UnifiedWorkoutManager
   
   init(workoutManager: UnifiedWorkoutManager) {
	  self.workoutManager = workoutManager
   }
   
   func userNotificationCenter(_ center: UNUserNotificationCenter,
							   didReceive response: UNNotificationResponse,
							   withCompletionHandler completionHandler: @escaping () -> Void) {
	  
	  switch response.actionIdentifier {
		 case "START_WORKOUT":
			workoutManager.userConfirmedWorkout()
		 case "IGNORE_WORKOUT":
			workoutManager.userDeclinedWorkout()
		 default:
			break
	  }
	  completionHandler()
   }
}
