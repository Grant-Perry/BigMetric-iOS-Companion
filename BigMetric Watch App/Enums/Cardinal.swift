//
//  Cardinal.swift
//  howFar Watch App
//
//  Created by Grant Perry on 3/30/23.
//

import SwiftUI

enum CardinalDirection: String {
   case north = "N",
        northeast = "NE",
        east = "E",
        southeast = "SE",
        south = "S",
        southwest = "SW",
        west = "W",
        northwest = "NW"

//  below is a computed property option
//   extension CLLocation {
//   var courseDirection: CardinalDirection {
//      let course = self.course

   init(course: CLLocationDirection) {
      switch course {
         case 0..<45:
            self = .north
         case 46..<90:
            self = .northeast
         case 91..<135:
            self = .east
         case 136..<180:
            self = .southeast
         case 181..<225:
            self = .south
         case 226..<270:
            self = .southwest
         case 271..<315:
            self = .west
         case 316..<360:
            self = .northwest
         default:
            self = .north
      }
   }

   var degrees: Double {
      switch self {
         case .north: return 0
         case .northeast: return 45
         case .east: return 90
         case .southeast: return 135
         case .south: return 180
         case .southwest: return 225
         case .west: return 270
         case .northwest: return 315
      }
   }
}

