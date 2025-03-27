//
//  PrecipChanceColor.swift
//  howFar Watch App
//
//  Created by Grant Perry on 5/3/23.
//
// Modified: 10/17/23

import Foundation
import SwiftUI

/// used to return a color (for tempature) based on a range from -175 degrees to 195 degrees
///
///
enum PrecipChanceColor {
   case veryLow // for chance < 20%
   case low // for chance < 40%
   case moderate // for chance < 60%
   case high // for chance < 80%
   case veryHigh // for chance >= 80%

   static func from(chance: Int) -> Color {
		let colors: [(Range<Int>, Color)] = [
			(-175..<0, 	Color(red: 0.5, 	green: 0.0, 	blue: 0.5)),   // -175 to -1: purple
			(0..<16, 	Color(red: 1.0, 	green: 1.0, 	blue: 1.0)),     // 0 to 15: white
			(16..<25, 	Color(red: 0.6, 	green: 0.8, 	blue: 0.95)),   // 16-24: light blue
			(25..<35, 	Color(red: 0.25, 	green: 0.6, 	blue: 0.8)),   // 25-34: light blue
			(35..<45, 	Color(red: 0.8, 	green: 0.95, 	blue: 0.8)),   // 35-44: very light green
			(45..<65, 	Color(red: 0.4, 	green: 0.97, 	blue: 0.8)),    // 45-64: greenish blue
			(65..<79, 	Color(red: 0.8, 	green: 0.95, 	blue: 0.8)),   // 65-78: light green
			(80..<95, 	Color(red: 1.0, 	green: 0.7, 	blue: 0.4)),    // 80-94: warm red to orange
			(95..<195,	Color(red: 1.0, 	green: 0.2, 	blue: 0.2))    // 95-194: hot red
		]



      for (range, color) in colors {
         if range.contains(chance) {
            return color
         }
      }
      return Color.clear
   }
}
