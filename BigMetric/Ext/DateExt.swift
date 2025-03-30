//   DateExt.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/12/24 at 4:14 PM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI

extension Date {
	func formatted(as format: String) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		return formatter.string(from: self)
	}
}
