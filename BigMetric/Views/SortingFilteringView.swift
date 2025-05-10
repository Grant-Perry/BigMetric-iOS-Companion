import SwiftUI

struct SortingFilteringView: View {
   @ObservedObject var polyViewModel: PolyViewModel
   @Environment(\.dismiss) private var dismiss

   // Default values for reset functionality
   private let defaultLimit = 45
   private let defaultStartDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
   private let defaultEndDate = Date()

   private var hasActiveFilters: Bool {
	  polyViewModel.shortRouteFilter ||
	  !Calendar.current.isDate(polyViewModel.startDate, equalTo: defaultStartDate, toGranularity: .day) ||
	  !Calendar.current.isDate(polyViewModel.endDate, equalTo: defaultEndDate, toGranularity: .day) ||
	  polyViewModel.limit != defaultLimit
   }

   var body: some View {
	  ZStack {
		 Color.black.ignoresSafeArea()

		 ScrollView {
			VStack(spacing: 20) {
			   // Active Filters Indicator
			   if hasActiveFilters {
				  HStack {
					 Image(systemName: "exclamationmark.circle.fill")
						.foregroundColor(.blue)
					 Text("Filters Active")
						.foregroundColor(.gray)
					 Spacer()
				  }
				  .padding(.horizontal)
			   }

			   // Filter Section
			   VStack(alignment: .leading, spacing: 16) {
				  Text("Filters")
					 .font(.headline)
					 .foregroundColor(.gray)
					 .padding(.horizontal)

				  Toggle(isOn: $polyViewModel.shortRouteFilter) {
					 VStack(alignment: .leading) {
						Text("Hide Short Routes")
						   .foregroundColor(.white)
						Text("< 0.1 miles")
						   .font(.caption)
						   .foregroundColor(.gray)
					 }
				  }
				  .padding()
				  .background(Color.gray.opacity(0.2))
				  .clipShape(RoundedRectangle(cornerRadius: 12))
			   }
			   .padding(.horizontal)

			   // Date Range Section
			   VStack(alignment: .leading, spacing: 16) {
				  HStack {
					 Text("Date Range")
						.font(.headline)
						.foregroundColor(.gray)
					 if !Calendar.current.isDate(polyViewModel.startDate, equalTo: defaultStartDate, toGranularity: .day) ||
						   !Calendar.current.isDate(polyViewModel.endDate, equalTo: defaultEndDate, toGranularity: .day) {
						Image(systemName: "circle.fill")
						   .foregroundColor(.blue)
						   .font(.system(size: 8))
					 }
				  }
				  .padding(.horizontal)

				  VStack(spacing: 12) {
					 DatePicker("Start Date", selection: $polyViewModel.startDate, displayedComponents: .date)
						.foregroundColor(.white)
						.tint(.blue)  // Make the date picker more visible

					 Divider().background(Color.gray.opacity(0.3))

					 DatePicker("End Date", selection: $polyViewModel.endDate, displayedComponents: .date)
						.foregroundColor(.white)
						.tint(.blue)  // Make the date picker more visible
				  }
				  .padding()
				  .background(Color.gray.opacity(0.2))
				  .clipShape(RoundedRectangle(cornerRadius: 12))
			   }
			   .padding(.horizontal)

			   // Results Section
			   VStack(alignment: .leading, spacing: 16) {
				  HStack {
					 Text("Date Range")
						.font(.headline)
						.foregroundColor(.gray)
					 if polyViewModel.limit != defaultLimit {
						Image(systemName: "circle.fill")
						   .foregroundColor(.blue)
						   .font(.system(size: 8))
					 }
				  }
				  .padding(.horizontal)

				  HStack {
					 Text("Results")
						.font(.headline)
						.foregroundColor(.gray)
					 if polyViewModel.filteredWorkoutCount > 0 {
						Text("(\(polyViewModel.filteredWorkoutCount) of \(polyViewModel.totalWorkoutCount))")
						   .font(.caption)
						   .foregroundColor(.gray)
					 }
				  }
				  .padding(.horizontal)

				  HStack {
					 Text("Show")
						.foregroundColor(.white)
					 Text("\(polyViewModel.limit)")
						.font(.headline)
						.foregroundColor(.blue)
						.frame(minWidth: 30)
					 Text("workouts")
						.foregroundColor(.white)

					 Spacer()

					 HStack(spacing: 20) {
						Button(action: {
						   polyViewModel.limit = max(10, polyViewModel.limit - 10)
						}) {
						   Image(systemName: "minus.circle.fill")
							  .font(.title2)
							  .foregroundColor(.blue)
						}

						Button(action: {
						   polyViewModel.limit = min(100, polyViewModel.limit + 10)
						}) {
						   Image(systemName: "plus.circle.fill")
							  .font(.title2)
							  .foregroundColor(.blue)
						}
					 }
				  }
				  .padding()
				  .background(Color.gray.opacity(0.2))
				  .clipShape(RoundedRectangle(cornerRadius: 12))
			   }
			   .padding(.horizontal)

			   Spacer(minLength: 30)

			   // Action Buttons
			   VStack(spacing: 16) {
				  Button(action: {
					 polyViewModel.loadWorkouts(page: 0)
					 dismiss()
				  }) {
					 Text("Apply Filters")
						.font(.headline)
						.foregroundColor(.white)
						.frame(maxWidth: .infinity)
						.padding()
						.background(hasActiveFilters ? Color.blue : Color.gray)
						.clipShape(RoundedRectangle(cornerRadius: 12))
				  }

				  if hasActiveFilters {
					 Button(action: {
						// Reset all filters to default
						polyViewModel.shortRouteFilter = false
						polyViewModel.startDate = defaultStartDate
						polyViewModel.endDate = defaultEndDate
						polyViewModel.limit = defaultLimit
					 }) {
						Text("Reset to Default")
						   .font(.subheadline)
						   .foregroundColor(.gray)
					 }
				  }

				  Button(action: {
					 dismiss()
				  }) {
					 Text("Cancel")
						.font(.subheadline)
						.foregroundColor(.gray)
				  }
			   }
			   .padding(.horizontal)
			   .padding(.bottom)
			}
		 }
	  }
	  .navigationTitle("Sort & Filter")
	  .navigationBarTitleDisplayMode(.inline)
	  .preferredColorScheme(.dark)
   }
}
