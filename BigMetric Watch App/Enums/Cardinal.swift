//
//  Cardinal.swift
//  howFar Watch App
//
//  Created by Grant Perry on 3/30/23.
//

import SwiftUI

enum CardinalDirection: String, CaseIterable {
   case north     = "N"
   case northEast = "NE"
   case east      = "E"
   case southEast = "SE"
   case south     = "S"
   case southWest = "SW"
   case west      = "W"
   case northWest = "NW"

   /// Only four primaries for the outer circles
   static var allPrimary: [CardinalDirection] {
	  [.north, .east, .south, .west]
   }

   /// Full human‑readable name
   var fullName: String {
	  switch self {
		 case .north:     return "North"
		 case .northEast: return "North East"
		 case .east:      return "East"
		 case .southEast: return "South East"
		 case .south:     return "South"
		 case .southWest: return "South West"
		 case .west:      return "West"
		 case .northWest: return "North West"
	  }
   }

   /// Angle around the dial (0° at top)
   var angle: Double {
	  switch self {
		 case .north:     return   0
		 case .northEast: return  45
		 case .east:      return  90
		 case .southEast: return 135
		 case .south:     return 180
		 case .southWest: return 225
		 case .west:      return 270
		 case .northWest: return 315
	  }
   }

   /// Pick the nearest of the eight for a given heading
   static func from(degrees: Double) -> CardinalDirection {
	  let idx = Int((degrees + 22.5) / 45.0) & 7
	  return allCases[idx]
   }
}
