//   GPSIconView.swift
//   BigMetric Watch App
//
//   Created by: Grant Perry on 1/1/24 at 11:57 AM
//     Modified: Saturday January 6, 2024 at 4:02:41 PM
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI

struct GPSIconView: View {
	var accuracy: Int
	var size: CGFloat

	var body: some View {
		VStack {
			VStack {
				Text("\(accuracy)")
					.font(.system(size: 12,
									  weight: .none))

					.rightJustify()
			}

			VStack {
				Image(systemName: "antenna.radiowaves.left.and.right")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: size)
					.horizontallyCentered()
					.foregroundColor(colorForAccuracy(accuracy))
			}
		}
	}
}

#Preview {
	GPSIconView(accuracy: 35,
					size: 25)
}
