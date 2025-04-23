//
//  CompassCenterDisplayView.swift
//  BigMetric Watch App
//

import SwiftUI
import CoreLocation

/// Displays the current heading, cardinal direction, and coordinate location with icon.
struct CompassCenterDisplayView: View {
   let headingDegrees: Double
   let cardinal: String
   var coordinate: CLLocationCoordinate2D?
   var locationName: String?

   var body: some View {
	  VStack(spacing: 6) {
		 Spacer()
		 Spacer()

		 HStack(spacing: 4) {
			Image(systemName: "mappin.and.ellipse")
			   .font(.system(size: 12))
			   .foregroundColor(.white.opacity(0.8))
			Spacer()
		 }
		 .frame(maxWidth: .infinity)

		 VStack(spacing: 0) {
			Text(String(format: "%.0f°", headingDegrees))
			   .font(.system(size: 32, weight: .bold))
			   .foregroundColor(.white)
			   .shadow(radius: 2)
			   .frame(maxWidth: .infinity, alignment: .center)

			if let locationName = locationName {
			   Text(locationName)
				  .font(.footnote)
				  .foregroundColor(.white.opacity(0.8))
				  .frame(maxWidth: .infinity)
				  .lineLimit(1)
				  .minimumScaleFactor(0.5)
				  .scaledToFit()
				  .offset(y: -10)

			}
		 }
		 .offset(y: 20)

		 Spacer()

		 //         if let coordinate = coordinate {
		 //            Text(String(format: "%.4f, %.4f", coordinate.latitude, coordinate.longitude))
		 //               .font(.footnote)
		 //               .foregroundColor(.white.opacity(0.7))
		 //         }
	  }
	  .frame(width: 120, height: 120)
	  .multilineTextAlignment(.center)
	  .padding(10)
	  .background(
		 Circle()
			.fill(Color.black.opacity(0.25))
	  )
   }
}

#Preview {
   CompassCenterDisplayView(
	  headingDegrees: 90,
	  cardinal: "NW",
	  coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
	  locationName: "Newport News"
   )
   .frame(width: 200, height: 200)
   .background(Color.black)
}
