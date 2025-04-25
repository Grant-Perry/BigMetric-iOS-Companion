import SwiftUI

/// Displays the rotating compass dial with tick marks and cardinal NESW
///  direction labels.
struct CompassDialView: View {
   var heading: Double  = 180
   // 0-360 degrees

   private func isNearThisCardinal(_ direction: CardinalDirection) -> Bool {
	  let normalizedHeading = heading.truncatingRemainder(dividingBy: 360)
	  return abs(normalizedHeading - direction.angle).truncatingRemainder(dividingBy: 360) <= 5
   }

   var body: some View {
	  GeometryReader { geo in
		 let size = min(geo.size.width, geo.size.height)
		 let tickRadius = size * 0.48
		 let cardinalRadius = size * 0.42
		 let tickMarksOn = true

		 ZStack {
			// Tick marks
			if tickMarksOn {
			   Group {
				  ForEach(0..<60, id: \.self) { tick in
					 let isCardinal = tick % 15 == 0
					 Rectangle()
						.fill(isCardinal ? Color.white : Color.gray.opacity(0.5))
						.frame(width: isCardinal ? 2 : 1,
							   height: isCardinal ? 12 : 6)
						.offset(y: -tickRadius)
						.rotationEffect(.degrees(Double(tick) * 6))
				  }
			   }
			}

			// Cardinal labels NESW - N, E, S, W
			ForEach(CardinalDirection.allPrimary, id: \.self) { direction in
			   let isNear = isNearThisCardinal(direction)
			   Text(direction.rawValue)
				  .font(.system(size: isNear ? 38 : 18, weight: .bold))
				  .foregroundColor(isNear ? .gpRed : .gpYellow)
				  .shadow(radius: 1)
				  .animation(.easeInOut(duration: 0.3), value: isNear)
				  .position(
					 x: geo.size.width / 2 + CGFloat(sin(direction.angle * .pi / 180)) * cardinalRadius,
					 y: geo.size.height / 2 - CGFloat(cos(direction.angle * .pi / 180)) * cardinalRadius
				  )
			}
		 }
		 .frame(width: size, height: size)
		 .scaleEffect(1.1)
	  }
   }
}

#Preview {
   CompassDialView(heading: 125)

	  .frame(width: 200, height: 200)
	  .background(Color.black)
}
