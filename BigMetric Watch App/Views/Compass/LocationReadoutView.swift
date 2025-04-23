//
//  LocationReadoutView.swift
//  BigMetric Watch App
//

import SwiftUI
import CoreLocation

/// Displays a location name or coordinates as optional readout at the bottom of the compass.
struct LocationReadoutView: View {
   let coordinate: CLLocationCoordinate2D?
   let locationName: String
   private let geoCodeHelper = GeoCodeHelper()
   @State private var currentLocationName: String = "Unknown"

   var body: some View {
	  VStack {
		 Spacer()
		 if let coordinate = coordinate {
			// If we have coordinates, try to get the location name
			if locationName.lowercased() != "unknown" {
			   Text("\(locationName)\n\(String(format: "%.4f", coordinate.latitude)), \(String(format: "%.4f", coordinate.longitude))")
				  .font(.footnote)
				  .foregroundColor(.white.opacity(0.8))
				  .multilineTextAlignment(.center)
			} else {
			   Text("\(String(format: "%.4f", coordinate.latitude)), \(String(format: "%.4f", coordinate.longitude))")
				  .font(.footnote)
				  .foregroundColor(.white.opacity(0.8))
				  .multilineTextAlignment(.center)
			}
		 } else if locationName.lowercased() != "unknown" {
			// Only show a name if it isn't "Unknown"
			Text(locationName)
			   .font(.footnote)
			   .foregroundColor(.white.opacity(0.8))
			   .multilineTextAlignment(.center)
		 }
	  }
	  .padding(.bottom, 10)
   }
}

#Preview {
   LocationReadoutView(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), locationName: "San Francisco")
	  .frame(width: 184, height: 224)
	  .background(Color.black)
}
