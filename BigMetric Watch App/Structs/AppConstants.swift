import SwiftUI

struct AppConstants {
   static let appName = "BigMetric"

   static func getVersion() -> String {
	  return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
   }
}
