import SwiftUI

/// Displays the rotating compass dial with tick marks and cardinal direction labels.
/// The red North pointer should remain static in the parent view.
struct CompassDialView: View {
   var heading: Double  = 180
   // 0-360 degrees

   var body: some View {
	  GeometryReader { geo in
		 let size = min(geo.size.width, geo.size.height)
		 let tickRadius = size * 0.48
		 let cardinalRadius = size * 0.42

		 ZStack {
			// Tick marks
			ForEach(0..<60, id: \.self) { tick in
			   let isCardinal = tick % 15 == 0
			   Rectangle()
				  .fill(isCardinal ? Color.white : Color.gray.opacity(0.5))
				  .frame(width: isCardinal ? 2 : 1,
						 height: isCardinal ? 12 : 6)
				  .offset(y: -tickRadius)
				  .rotationEffect(.degrees(Double(tick) * 6))
			}

			// Cardinal labels
			ForEach(CardinalDirection.allPrimary, id: \.self) { direction in
			   Text(direction.rawValue)
				  .font(.system(size: 20, weight: .bold))
				  .foregroundColor(.white)
				  .shadow(radius: 1)
				  .position(
					 x: geo.size.width / 2 + CGFloat(sin(direction.angle * .pi / 180)) * cardinalRadius,
					 y: geo.size.height / 2 - CGFloat(cos(direction.angle * .pi / 180)) * cardinalRadius
				  )
			}
		 }
		 .frame(width: size, height: size)
	  }
   }
}

#Preview {
   CompassDialView(heading: 125)

	  .frame(width: 200, height: 200)
	  .background(Color.black)
}
