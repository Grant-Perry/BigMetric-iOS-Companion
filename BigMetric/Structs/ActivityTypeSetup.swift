//
//  ActivityTypeSetup.swift
//  BigMetric Watch App
//
//  .walk, .run, .bike => distinct speed thresholds & HK types

import SwiftUI
import HealthKit

/// ``ActivityTypeSetup``
/// Matches old debug logic: .walk => 20 mph, .run => 35, .bike => 50
enum ActivityTypeSetup: String, Identifiable {
   case walk
   case run
   case bike
   
   var id: String { rawValue }
   
   var hkActivityType: HKWorkoutActivityType {
	  switch self {
		 case .walk: return .walking
		 case .run:  return .running
		 case .bike: return .cycling
	  }
   }
   
   var maxSpeed: Double {
	  switch self {
		 case .walk: return 20.0
		 case .run:  return 35.0
		 case .bike: return 50.0
	  }
   }
   
   var sfSymbol: String {
	  switch self {
		 case .walk: return "figure.walk"
		 case .run:  return "figure.run"
		 case .bike: return "bicycle"
	  }
   }
}
