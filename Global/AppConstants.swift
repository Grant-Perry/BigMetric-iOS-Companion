import SwiftUI

struct AppConstants {
   static let appName = "BigMetric"
   static let title = "My Workouts"
   static let workoutCoreDebug = false
   static let weatherDebug = false

   static func getVersion() -> String {
	  return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
   }
   
}
