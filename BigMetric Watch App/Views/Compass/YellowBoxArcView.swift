import SwiftUI
import CoreLocation
import Orb

struct YellowBoxArcView: View {
   let heading: Double
   @Environment(\.self) var environment

   let boxCount: Int = 60
   let boxSize: CGFloat = 6
   let ringScale: CGFloat = 1.05
   let orbMagnifier = 0.8  // ADD: Control the orb size

   var orbConfig: OrbConfiguration {
	  OrbConfiguration(
		 backgroundColors: [.yellow, .green, .pink],
		 glowColor: .white,
		 coreGlowIntensity: 1.0,
		 showWavyBlobs: true,
		 showParticles: true,
		 showGlowEffects: true,
		 showShadow: true,
		 speed: 40
	  )
   }

   var body: some View {
	  GeometryReader { geo in
		 let size = min(geo.size.width, geo.size.height)

		 ZStack {
			// ADD: White circle with blur for sparkle effect
			Circle()
			   .fill(Color.white)
			   .frame(width: size * orbMagnifier, height: size * orbMagnifier)
			   .blur(radius: 23)
			   .opacity(0.47)

			// ADD: Overlay the orb
			OrbView(configuration: orbConfig)
			   .aspectRatio(1, contentMode: .fit)
			   .frame(width: size * orbMagnifier, height: size * orbMagnifier)

			CompassYellowRing(
			   boxCount: boxCount,
			   boxSize: boxSize,
			   heading: heading,
			   highlightRange: 45
			)
			.frame(width: size, height: size)
		 }
		 .scaleEffect(ringScale)
		 .frame(width: geo.size.width, height: geo.size.height)
	  }
   }
}

#Preview {
   YellowBoxArcView(heading: 0)
	  .background(Color.black)
}
