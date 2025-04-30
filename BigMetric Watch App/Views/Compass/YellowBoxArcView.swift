import SwiftUI
import CoreLocation
import Orb

struct YellowBoxArcView: View {
   @Environment(MyOrbViewModel.self) private var myOrbViewModel
   
   let heading: Double
   let rotateBGMode: Bool
   let orbMagnifier = 0.76  // size of the orb
   
   
   var orbConfig: OrbConfiguration {
	  OrbConfiguration(
		 backgroundColors: [
			myOrbViewModel.orbColor1,
			myOrbViewModel.orbColor2,
			myOrbViewModel.orbColor3
		 ],
		 glowColor: .gpLtBlue,
		 coreGlowIntensity: 1.0,
		 showWavyBlobs: true,
		 showParticles: true,
		 showGlowEffects: true,
		 showShadow: true,
		 speed: 25
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
			   .opacity(0.25)
			
			
			OrbView(configuration: orbConfig)
			   .aspectRatio(1, contentMode: .fit)
			   .frame(width: size * orbMagnifier, height: size * orbMagnifier)
			
			CompassYellowRing(heading: heading, rotateBGMode: rotateBGMode)
			   .frame(width: size, height: size)
		 }
		 .scaleEffect(1.08)
		 .frame(width: geo.size.width, height: geo.size.height)
	  }
   }
}
