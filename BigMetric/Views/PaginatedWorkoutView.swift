import SwiftUI
import HealthKit
import Observation

struct PaginatedWorkoutsView: View {
   @ObservedObject var polyViewModel: PolyViewModel
   @State private var currentPage = 0
   @State private var showingFilters = false

   private var hasActiveFilters: Bool {
	  polyViewModel.shortRouteFilter ||
	  !Calendar.current.isDate(polyViewModel.startDate,
							   equalTo: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
							   toGranularity: .day) ||
	  !Calendar.current.isDate(polyViewModel.endDate, equalTo: Date(), toGranularity: .day)
   }

   var body: some View {
	  NavigationStack {
		 ZStack {
			Color.black.ignoresSafeArea()

			VStack(spacing: 0) {
			   HStack {
				  Text("My Workouts")
					 .font(.system(size: 34, weight: .bold))
					 .foregroundColor(.white)
				  if hasActiveFilters && polyViewModel.filteredWorkoutCount > 0 {
					 Text("(\(polyViewModel.filteredWorkoutCount))")
						.font(.system(size: 20))
						.foregroundColor(.gray)
				  }
				  Spacer()
				  Button {
					 showingFilters = true
				  } label: {
					 Image(systemName: hasActiveFilters ? "slider.horizontal.3" : "slider.horizontal.3")
						.font(.title2)
						.foregroundStyle(hasActiveFilters ? .blue : .white)
						.padding(8)
						.background(Color.gray.opacity(0.3))
						.clipShape(RoundedRectangle(cornerRadius: 8))
				  }
				  .padding(.trailing)
			   }
			   .padding(.horizontal)
			   .padding(.top, 8)
			   .padding(.bottom, 24)

			   if polyViewModel.workouts.isEmpty && polyViewModel.isLoading {
				  Spacer()
				  ProgressView("Loading Workouts...")
					 .tint(.white)
					 .foregroundColor(.gray)
				  Spacer()
			   } else if polyViewModel.workouts.isEmpty {
				  Spacer()
				  VStack(spacing: 12) {
					 Image(systemName: "figure.walk")
						.font(.system(size: 40))
						.foregroundColor(.gray)
					 Text("No workouts found")
						.foregroundColor(.gray)
					 if hasActiveFilters {
						Text("Try adjusting your filters")
						   .font(.caption)
						   .foregroundColor(.gray.opacity(0.7))
					 }
				  }
				  Spacer()
			   } else {
				  ScrollView {
					 LazyVStack(spacing: 16) {
						ForEach(polyViewModel.workouts, id: \.uuid) { workout in
						   NavigationLink(destination: FullMapView(workout: workout, polyViewModel: polyViewModel)) {
							  WorkoutRouteView(workout: workout, polyViewModel: polyViewModel)
						   }
						}
					 }
					 .padding(.horizontal)
				  }
				  .scrollIndicators(.hidden)
			   }

			   Text("\(AppConstants.appName) - ver: \(AppConstants.getVersion())")
				  .font(.system(size: 14))
				  .foregroundColor(.white)
				  .frame(maxWidth: .infinity, alignment: .center)
				  .padding(.bottom, 8)
			}
		 }
	  }
	  .sheet(isPresented: $showingFilters) {
		 NavigationStack {
			SortingFilteringView(polyViewModel: polyViewModel)
		 }
	  }
	  .preferredColorScheme(.dark)
	  .onAppear {
		 currentPage = 0
		 polyViewModel.loadWorkouts(page: currentPage)
	  }
   }
}
