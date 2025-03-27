import SwiftUI

struct SummaryMetricView: View {
   var title: String
   var value: String
   var textSize: Int = 14

   var body: some View {
	  VStack(alignment: .leading, spacing: 4) {
		 Text(title)
			.font(.system(size: CGFloat(textSize - 6), weight: .semibold))
			.foregroundColor(.secondary)

		 Text(value)
			.font(.system(size: CGFloat(textSize), weight: .bold))
			.foregroundColor(.primary)

		 Divider()
	  }
	  .padding(.vertical, 2)
   }
}
