import SwiftUI
import HealthKit

struct WorkoutRouteView: View {
   let workout: HKWorkout
   @StateObject private var workoutRouteViewModel: WorkoutRouteViewModel

   init(workout: HKWorkout, polyViewModel: PolyViewModel) {
	  self.workout = workout
	  self._workoutRouteViewModel = StateObject(wrappedValue: WorkoutRouteViewModel(workout: workout, polyViewModel: polyViewModel))
   }

   var body: some View {
	  VStack(spacing: 4) {
		 if workoutRouteViewModel.isLoading {
			WorkoutLoadingView()
		 } else if workoutRouteViewModel.isError {
			WorkoutErrorView(message: workoutRouteViewModel.errorMessage)
		 } else if workoutRouteViewModel.isDataLoaded {
			VStack(spacing: 8) {
			   WorkoutHeaderView(
				  cityName: workoutRouteViewModel.cityName,
				  address: workoutRouteViewModel.address,
				  routeStartDate: workoutRouteViewModel.routeStartDate,
				  weatherTemp: workoutRouteViewModel.weatherTemp,
				  weatherSymbol: workoutRouteViewModel.weatherSymbol
			   )

			   WorkoutMetricsGridView(
				  formattedTotalTime: workoutRouteViewModel.formattedTotalTime,
				  distance: workoutRouteViewModel.distance,
				  pace: workoutRouteViewModel.formatPaceMinMi(),
				  weatherTemp: workoutRouteViewModel.weatherTemp,
				  weatherSymbol: workoutRouteViewModel.weatherSymbol
			   )
			   .padding(.horizontal, 12)
			   .padding(.bottom, 12)
			}
			.background(
			   GeometryReader { geometry in
				  ZStack {
					 if let symbol = workoutRouteViewModel.weatherSymbol {
						Image(WeatherGradient(from: symbol).backgroundImage)
						   .resizable()
						   .aspectRatio(contentMode: .fill)
						   .frame(width: geometry.size.width, height: geometry.size.height)
						   .opacity(0.95)
					 } else {
						Image(WeatherGradient.default.backgroundImage)
						   .resizable()
						   .aspectRatio(contentMode: .fill)
						   .frame(width: geometry.size.width, height: geometry.size.height)
						   .opacity(0.95)
					 }
					 Color.black.opacity(0.15)
				  }
			   }
			)
			.clipShape(RoundedRectangle(cornerRadius: 24))
			.shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
			.opacity(workoutRouteViewModel.appeared ? 1 : 0)
			.offset(y: workoutRouteViewModel.appeared ? 0 : 50)
			.animation(.spring(response: 0.6, dampingFraction: 0.8), value: workoutRouteViewModel.appeared)
			.onAppear { workoutRouteViewModel.appeared = true }
		 }
	  }
	  .padding(.vertical, 2)
   }
}
