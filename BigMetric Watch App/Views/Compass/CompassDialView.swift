import SwiftUI

/// Displays the rotating compass dial with tick marks and cardinal NESW
///  direction labels.
struct CompassDialView: View {
   var heading: Double = 180

   private func isNearThisCardinal(_ direction: CardinalDirection) -> Bool {
	  let normalizedHeading = heading.truncatingRemainder(dividingBy: 360)
	  return abs(normalizedHeading - direction.angle).truncatingRemainder(dividingBy: 360) <= 5
   }

   private func tickMarks(radius: CGFloat) -> some View {
	  Group {
		 ForEach(0..<60, id: \.self) { tick in
			let isCardinal = tick % 15 == 0
			Rectangle()
			   .fill(isCardinal ? Color.white : Color.gray.opacity(0.5))
			   .frame(width: isCardinal ? 2 : 1,
					  height: isCardinal ? 12 : 6)
			   .offset(y: -radius)
			   .rotationEffect(.degrees(Double(tick) * 6))
		 }
	  }
   }

   private func cardinalLabel(direction: CardinalDirection, radius: CGFloat, center: CGPoint) -> some View {
	  let isNear = isNearThisCardinal(direction)
	  return ZStack {
		 if isNear {
			Text(direction.rawValue)
			   .font(.system(size: 30, weight: .bold))
			   .foregroundColor(.gpRed)
			   .shadow(color: .white, radius: 0.5)
		 } else {
			Text(direction.rawValue)
			   .font(.system(size: 18, weight: .bold))
			   .foregroundColor(.gpYellow)
		 }
	  }
	  .animation(.easeInOut(duration: 0.3), value: isNear)
	  .position(
		 x: center.x + CGFloat(sin(direction.angle * .pi / 180)) * radius,
		 y: center.y - CGFloat(cos(direction.angle * .pi / 180)) * radius
	  )
   }

   var body: some View {
	  GeometryReader { geo in
		 let size = min(geo.size.width, geo.size.height)
		 let tickRadius = size * 0.48
		 let cardinalRadius = size * 0.42
		 let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

		 ZStack {
			tickMarks(radius: tickRadius)

			ForEach(CardinalDirection.allPrimary, id: \.self) { direction in
			   cardinalLabel(direction: direction, radius: cardinalRadius, center: center)
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
