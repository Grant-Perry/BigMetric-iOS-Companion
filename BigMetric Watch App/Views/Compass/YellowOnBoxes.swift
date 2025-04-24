import SwiftUI
import CoreLocation
import Orb
import Foundation

struct YellowOnBoxes: View {
   let heading: Double
   let boxCount: Int = 60
   let boxSize: CGFloat = 6
   let ringScale: CGFloat = 1.1

   private var angleStep: Double { 360.0 / Double(boxCount) }

   private var boxGradient: AnyShapeStyle {
	  .init(
		 AngularGradient(
			gradient: Gradient(colors: [.gpWhite, .gpOrange]),
			center: .center,
			startAngle: .degrees(-45),
			endAngle: .degrees(45)
		 )
	  )
   }

   var body: some View {
	  GeometryReader { geo in
		 let size = min(geo.size.width, geo.size.height)
		 let baseR = size * 0.45
		 let rCenter = baseR + boxSize/2

		 ZStack {
			// Rotating illuminated pattern
			ZStack {
			   // Center box
			   Rectangle()
				  .fill(boxGradient)
				  .frame(width: boxSize, height: boxSize)
				  .offset(
					 x: rCenter * CGFloat(cos(Double(0))),
					 y: rCenter * CGFloat(sin(Double(0)))
				  )

			   // Adjacent boxes
			   ForEach([-1, 1], id: \.self) { offset in
				  Rectangle()
					 .fill(boxGradient)
					 .frame(width: boxSize, height: boxSize)
					 .offset(
						x: rCenter * CGFloat(cos(Double(offset) * angleStep * .pi/180)),
						y: rCenter * CGFloat(sin(Double(offset) * angleStep * .pi/180))
					 )
					 .opacity(0.6)
			   }

			   // Adjacent-adjacent boxes
			   ForEach([-2, 2], id: \.self) { offset in
				  Rectangle()
					 .fill(boxGradient)
					 .frame(width: boxSize, height: boxSize)
					 .offset(
						x: rCenter * CGFloat(cos(Double(offset) * angleStep * .pi/180)),
						y: rCenter * CGFloat(sin(Double(offset) * angleStep * .pi/180))
					 )
					 .opacity(0.3)
			   }
			}
			.rotationEffect(.degrees(-90))
			.rotationEffect(.degrees(heading))
		 }
	  }
   }
}
