import SwiftUI

/// Represents the overall workout lifecycle state within UnifiedWorkoutManager.
enum WorkoutState: String {
   case notStarted
   case running
   case paused
   case ended
}
