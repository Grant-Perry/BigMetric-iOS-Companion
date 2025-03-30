import SwiftUI

@main
struct BigMetric: App {
   @StateObject private var polyViewModel = PolyViewModel()
   var body: some Scene {
	  WindowGroup {
		 PaginatedWorkoutsView(polyViewModel: polyViewModel)
	  }
   }
}

