import SwiftUI
import CoreLocation
import Orb

/// A ring of `boxCount` squares, each sized `boxSize`, 
/// all oriented tangentially so that their bottom edge sits 
/// exactly on a circle of radius = 45% of the container.
/// Boxes within ±`highlightRange`° of `heading` get a yellow→orange 
/// gradient; the rest are gray.
struct CompassYellowRing: View {
   let heading: Double
   let highlightRange: Double = 45
   
   let boxCount: Int = 60
   let boxSize: CGFloat = 6
   let ringScale: CGFloat = 1.1
   
   private var angleStep: Double { 360.0 / Double(boxCount) }
   
   var body: some View {
	  GeometryReader { geo in
		 let size = min(geo.size.width, geo.size.height)
		 let baseR = size * 0.45
		 let rCenter = baseR + boxSize/2
		 
		 ZStack {
			ForEach(0..<boxCount, id: \.self) { i in
			   let angleDeg = Double(i) * angleStep
			   let angleRad = angleDeg * .pi/180
			   
			   // CHANGE: Fix highlight calculation to match compass direction
			   let delta = abs((angleDeg - heading + 90)
				  .truncatingRemainder(dividingBy: 360))
			   let dist = delta > 180 ? 360 - delta : delta
			   
			   let intensity = max(0, 1 - (dist / highlightRange))
			   let fill: AnyShapeStyle = .init(
				  AngularGradient(
					 gradient: Gradient(colors: [
						.yellow.opacity(intensity),
						.gpOrange.opacity(intensity * 0.8)
					 ]),
					 center: .center,
					 startAngle: .degrees(angleDeg - angleStep/2),
					 endAngle: .degrees(angleDeg + angleStep/2)
				  )
			   )
			   
			   Rectangle()
				  .fill(fill)
				  .frame(width: boxSize, height: boxSize)
				  .rotationEffect(.degrees(angleDeg))
				  .offset(
					 x: rCenter * CGFloat(cos(angleRad)),
					 y: rCenter * CGFloat(sin(angleRad))
				  )
			}
		 }
		 .rotationEffect(.degrees(-90))
		 .frame(width: size, height: size)
		 .animation(.easeOut(duration: 0.3), value: heading)
	  }
   }
}

// Preview showing different compass directions
struct CompassYellowRing_Previews: PreviewProvider {
   static var previews: some View {
	  VStack(spacing: 20) {
		 CompassYellowRing(
			heading: 0
		 )
		 .frame(width: 200, height: 200)
		 
		 CompassYellowRing(
			heading: 90
		 )
		 .frame(width: 200, height: 200)
		 
		 CompassYellowRing(
			heading: 180
		 )
		 .frame(width: 200, height: 200)
	  }
	  .padding()
	  .background(Color.black)
	  .previewLayout(.sizeThatFits)
   }
}
