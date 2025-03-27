import HealthKit

extension HKWorkoutBuilder {
   func endCollectionAsync(withEnd endDate: Date) async throws {
	  try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
		 self.endCollection(withEnd: endDate) { success, error in
			if let error = error {
			   continuation.resume(throwing: error)
			} else {
			   continuation.resume(returning: ())
			}
		 }
	  }
   }

   func addMetadataAsync(_ metadata: [String: Any]) async throws {
	  try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
		 self.addMetadata(metadata) { success, error in
			if let error = error {
			   continuation.resume(throwing: error)
			} else {
			   continuation.resume(returning: ())
			}
		 }
	  }
   }

   func finishWorkoutAsync() async throws -> HKWorkout {
	  try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<HKWorkout, Error>) in
		 self.finishWorkout { workout, error in
			if let error = error {
			   continuation.resume(throwing: error)
			} else if let workout = workout {
			   continuation.resume(returning: workout)
			} else {
			   continuation.resume(throwing: NSError(
				  domain: "HKWorkoutBuilder",
				  code: -1,
				  userInfo: [NSLocalizedDescriptionKey: "Failed to create workout"]
			   ))
			}
		 }
	  }
   }
}

extension HKWorkoutRouteBuilder {
   func finishRouteAsync(with workout: HKWorkout, metadata: [String: Any]?) async throws {
	  try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
		 self.finishRoute(with: workout, metadata: metadata) { route, error in
			if let error = error {
			   continuation.resume(throwing: error)
			} else {
			   continuation.resume(returning: ())
			}
		 }
	  }
   }
}

// End of file
