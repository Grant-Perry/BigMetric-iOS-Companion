import SwiftUI

struct WorkoutRouteHeaderView: View {
   let routeStartDate: Date?
   let address: Address?
   let cityName: String
   let weatherTemp: String?
   let weatherSymbol: String?
   let dateFormatter: DateFormatter

   var body: some View {
	  VStack(alignment: .leading, spacing: 6) {
		 if let routeDate = routeStartDate {
			Text(routeDate, formatter: dateFormatter)
			   .font(.system(size: 15))
			   .foregroundColor(.white)
			   .fontDesign(.rounded)
		 }

		 if let address = address {
			Text(address.city)
			   .font(.system(size: 28, weight: .bold))
			   .foregroundColor(.white)
			   .fontDesign(.rounded)
		 } else {
			Text(cityName)
			   .font(.system(size: 28, weight: .bold))
			   .foregroundColor(.white)
			   .fontDesign(.rounded)
		 }

		 if let wTemp = weatherTemp, let wSymbol = weatherSymbol {
			HStack(spacing: 6) {
			   Image(systemName: wSymbol)
				  .font(.system(size: 16))
			   Text("\(wTemp)°")
				  .font(.system(size: 16, weight: .medium))
				  .fontDesign(.rounded)
			}
			.foregroundColor(.white.opacity(0.9))
		 }
	  }
	  .padding(.horizontal)
	  .padding(.top, 12)
   }
}
