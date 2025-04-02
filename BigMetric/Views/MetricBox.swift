import SwiftUI

struct MetricBox: View {
   let title: String
   let value: String
   let textSize: Int
   let iconName: String

   init(title: String, value: String, textSize: Int, iconName: String = "questionmark.circle") {
	  self.title = title
	  self.value = value
	  self.textSize = textSize
	  self.iconName = iconName
   }

   var body: some View {
	  VStack(alignment: .leading, spacing: 4) {
		 HStack(spacing: 8) {
			Image(systemName: iconName)
			   .font(.system(size: 19))
			   .foregroundColor(.white)
			   .opacity(0.7)

			Text("\(title):")
			   .font(.system(size: 19))
			   .fontWeight(.heavy)
			   .foregroundColor(.white)
			   .opacity(0.7)
		 }
		 HStack {
			Text(value)
			   .font(.system(size: CGFloat(textSize)).weight(.light))
			   .foregroundColor(.white)
			   .opacity(0.65)
			   .minimumScaleFactor(0.3)
			   .lineLimit(1)

			Spacer()
		 }
		 .padding(12)
		 .frame(maxWidth: .infinity)
		 .background(Color.white.opacity(0.15))
		 .cornerRadius(15)
	  }
   }
}
