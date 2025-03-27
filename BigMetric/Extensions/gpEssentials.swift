//
//  gpStuff.swift
//  howFar Watch App
//
//  Created by Grant Perry on 4/13/23.
//

import Foundation
import UIKit
import SwiftUI

	/// A utility structure for formatting numeric values.
struct gpNumFormat {

		/// Formats a numeric value to a string with a specified number of decimal places.
		/// This method can handle any type that conforms to `BinaryFloatingPoint`, which includes
		/// standard floating-point types such as `Float`, `Double`, and `CGFloat`.
		///
		/// - Parameters:
		///   - [number:]: The number to be formatted. It must conform to `BinaryFloatingPoint`.
		///   - [decimalPlaces:]: The number of decimal places to include in the formatted string.
		///     If `0`, the number is rounded to the nearest whole number.
		/// - Returns: A `String` representation of the number formatted to the specified number of decimal places.
		///
		/// Example usage:
		/// ```
		/// let newFormatNum = gpNumFormat.formatNumber(1234.5678, 1) // returns: "1234.5"
		/// ```
	static func formatNumber<numToFix: BinaryFloatingPoint>(_ number: numToFix, _ decimalPlaces: Int) -> String {
			// If the caller requests no decimal places, format the number as an integer.
		if decimalPlaces == 0 {
			return String(format: "%.0f", Double(number))
		} else {
				// Construct a format string using the specified number of decimal places.
				// This allows for dynamic adjustment of the number of decimals in the output.
			let formatString = "%.\(decimalPlaces)f"
				// Use the format string to format the number, casting it to Double to satisfy the String format method.
			return String(format: formatString, Double(number))
		}
	}
}


struct gpDateStuff {

   static func  getDayName(daysFromToday numDaysFromToday: Int) -> String {

      //      var numDaysFromToday = 0
      
      let tomorrow = Calendar.current.date(byAdding: .day, value: numDaysFromToday, to: Date())!
      let dayOfWeek = DateFormatter().shortWeekdaySymbols[Calendar.current.component(.weekday, from: tomorrow) - 1]
      //      dayOfWeek.dateFormat = "EEE"
      return dayOfWeek
   }
}


/// Make a button a double-click button
/// USAGE:
/// DoubleClickButton(Action: { }
struct DoubleClickButton<Content: View>: View {
   @State var selectedTab = 2
   let action: () -> Void
   let content: Content

   init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
      self.action = action
      self.content = content()
		

   }

   var body: some View {
      content

         .onTapGesture(count: 2, perform: action)


         
   }
}
