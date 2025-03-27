//   GPSAccuracyColor.swift
//   BigMetric Watch App
//
//   Created by: Grant Perry on 1/1/24 at 11:43 AM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
/// enum to modify the color of the GPS symbol on the main screen
//

import CoreLocation
import SwiftUI

// Enum to represent accuracy levels
enum GPSAccuracyColor {
	case gpRed, gpPink, gpYellow, gpBlue, gpGreen

	// Initialize based on an integer representing accuracy
	init(accuracy: Int) {
		switch accuracy {
			case 50...:
				self = .gpRed
			case 40..<50:
				self = .gpPink
			case 30..<40:
				self = .gpYellow
			case 20..<30:
				self = .gpBlue
			default:
				self = .gpGreen
		}
	}

	// Corresponding predefined color
	var color: Color {
		switch self {
			case .gpRed:
				return Color.gpRed
			case .gpYellow:
				return Color.gpPink
			case .gpPink:
				return Color.gpYellow
			case .gpBlue:
				return Color.gpBlue
			case .gpGreen:
				return Color.gpGreen
		}
	}
}

// Function to get predefined color based on an integer accuracy value
func colorForAccuracy(_ accuracy: Int) -> Color {
	return GPSAccuracyColor(accuracy: accuracy).color
}
