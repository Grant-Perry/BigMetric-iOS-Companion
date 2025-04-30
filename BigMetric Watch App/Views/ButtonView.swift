//
//  buttonVIew.swift
//  howFar Watch App
//
//  Created by Grant Perry on 4/2/23.
//                Modified on: Sunday December 31, 2023 at 10:28:20 AM
//

import SwiftUI
import WatchKit
import Orb

struct ButtonView: View {
   @Environment(MyOrbViewModel.self) private var myOrbViewModel
   var stateBtnColor 	= Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
   var startColor 		= Color(#colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1))
   var endColor 			= Color(#colorLiteral(red: 1, green: 0.1271572973, blue: 0.969772532, alpha: 1))
   var isUp: Bool
   var screenBounds = WKInterfaceDevice.current().screenBounds
   // [.gpGreen, .gpRed, .blue]
   
   var config: OrbConfiguration {
	  OrbConfiguration(
		 backgroundColors: [
			myOrbViewModel.orbColor1,
			myOrbViewModel.orbColor2,
			myOrbViewModel.orbColor3
		 ],
		 glowColor: .white,
		 coreGlowIntensity: isUp ? 1.0 : 0.25,
		 showWavyBlobs: true,
		 showParticles: isUp,
		 showGlowEffects: isUp,
		 showShadow: isUp,
		 speed: isUp ? 40 : 30
	  )
   }
   
   var body: some View {
	  VStack(alignment: .center, spacing:0) {
		 ZStack {
			Circle()
			   .fill(stateBtnColor)
			   .frame(width: (screenBounds.width/1.5) * 1.03, height: (screenBounds.height/1.5) * 1.03)
			   .blur(radius: self.isUp ? 13 : 0)
		 }
		 .overlay(
			OrbView(configuration: config)
			   .aspectRatio(1, contentMode: .fit)
			   .frame(width: (screenBounds.width/1.35) * 0.85,
					  height: (screenBounds.height/1.5) * 0.95)
		 )
	  }
   }
}

#Preview {
   ButtonView(isUp: true)
}
