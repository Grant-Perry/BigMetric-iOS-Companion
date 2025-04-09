import SwiftUI
import HealthKit

struct WorkoutRouteView: View {
   let workout: HKWorkout
   @StateObject private var viewModel: WorkoutRouteViewModel

   init(workout: HKWorkout, polyViewModel: PolyViewModel) {
	  self.workout = workout
	  self._viewModel = StateObject(wrappedValue: WorkoutRouteViewModel(workout: workout, polyViewModel: polyViewModel))
   }

   private var dateFormatter: DateFormatter {
	  let df = DateFormatter()
	  df.dateStyle = .medium
	  return df
   }

   private var timeFormatter: DateFormatter {
	  let df = DateFormatter()
	  df.timeStyle = .short
	  return df
   }

   var body: some View {
	  ScrollView {
		 VStack(spacing: 4) {
			if viewModel.isLoading {
			   WorkoutLoadingView()
			} else if viewModel.isError {
			   WorkoutErrorView(message: viewModel.errorMessage)
			} else {
			   VStack(spacing: 12) {
				  WorkoutHeaderView(
					 cityName: viewModel.cityName,
					 address: viewModel.address,
					 routeStartDate: viewModel.routeStartDate,
					 weatherTemp: viewModel.weatherTemp,
					 weatherSymbol: viewModel.weatherSymbol
				  )

				  WorkoutMetricsGridView(
					 formattedTotalTime: viewModel.formattedTotalTime,
					 distance: viewModel.distance,
					 pace: viewModel.formatPaceMinMi(),
					 weatherTemp: viewModel.weatherTemp,
					 weatherSymbol: viewModel.weatherSymbol
				  )
				  .padding(.horizontal, 16)
				  .padding(.bottom, 8)
			   }
			   .background(
				  Group {
					 Image(viewModel.weatherSymbol != nil ?
						   WeatherGradient(from: viewModel.weatherSymbol).backgroundImage :
							  WeatherGradient.default.backgroundImage)
					 .resizable()
					 .aspectRatio(contentMode: .fill)
					 .opacity(0.95)
					 Color.black.opacity(0.15)
				  }
			   )
			   .clipShape(RoundedRectangle(cornerRadius: 16))
			   .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
			   .padding(.horizontal, 12)
			   .opacity(viewModel.appeared ? 1 : 0)
			   .offset(y: viewModel.appeared ? 0 : 50)
			   .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.appeared)
			   .onAppear { viewModel.appeared = true }
			}
		 }
		 .padding(.vertical, 2)
	  }
	  .scrollTargetBehavior(.viewAligned)
	  .task {
		 await viewModel.loadWorkoutData()
	  }
   }
}

