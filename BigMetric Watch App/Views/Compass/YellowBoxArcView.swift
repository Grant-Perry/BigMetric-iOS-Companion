import SwiftUI
import CoreLocation
import Orb

struct YellowBoxArcView: View {
   let heading: Double

   let orbMagnifier = 0.8

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
			Circle()
			   .fill(Color.white)
			   .frame(width: size * orbMagnifier, height: size * orbMagnifier)
			   .blur(radius: 23)
			   .opacity(0.47)

			OrbView(configuration: orbConfig)
			   .aspectRatio(1, contentMode: .fit)
			   .frame(width: size * orbMagnifier, height: size * orbMagnifier)

			CompassYellowRing(heading: heading)
			   .frame(width: size, height: size)
		 }
		 .scaleEffect(1.05)
		 .frame(width: geo.size.width, height: geo.size.height)
	  }
   }
}

#Preview {
   YellowBoxArcView(heading: 0)
	  .background(Color.black)
}
