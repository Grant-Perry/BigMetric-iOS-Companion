import SwiftUI
import Orb

struct WatchColorPickerView: View {
   @Environment(MyOrbViewModel.self) private var myOrbViewModel
   
   var body: some View {
	  VStack(spacing: 8) {
		 Text("Setting Color \(myOrbViewModel.colorIndex + 1)")
			.font(.caption)
			.foregroundColor(.white.opacity(0.8))
		 
		 let availableColors: [Color] = [
			.red, .orange, .yellow, .green, .blue, .purple,
			.pink, .white, .gray, .cyan, .mint, .indigo
		 ]
		 
		 LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
			ForEach(availableColors, id: \.self) { color in
			   Button(action: {
				  myOrbViewModel.updateNextColor(to: color)
			   }) {
				  RoundedRectangle(cornerRadius: 6)
					 .fill(color)
					 .frame(width: 30, height: 30)
					 .overlay(
						RoundedRectangle(cornerRadius: 6)
						   .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
					 )
			   }
			}
		 }
		 .frame(maxWidth: 140)
		 
		 OrbView(configuration: OrbConfiguration(
			backgroundColors: [
			   myOrbViewModel.orbColor1 == .black ? .green : myOrbViewModel.orbColor1,
			   myOrbViewModel.orbColor2 == .black ? .blue : myOrbViewModel.orbColor2,
			   myOrbViewModel.orbColor3 == .black ? .pink : myOrbViewModel.orbColor3
			   // Originally defaulted to: .yellow, .green, .pink
			   // To restore original: .yellow, .green, .pink
			],
			glowColor: .white,
			coreGlowIntensity: 1.0,
			showWavyBlobs: true,
			showParticles: true,
			showGlowEffects: true,
			showShadow: true,
			speed: 40
		 ))
		 .aspectRatio(1, contentMode: .fit)
		 .frame(width: 80, height: 80)
		 
		 HStack(spacing: 6) {
			Text("Current:")
			   .font(.caption2)
			   .foregroundColor(.white)
			Circle()
			   .fill(currentOrbColor)
			   .frame(width: 20, height: 20)
			   .shadow(radius: 2)
		 }
	  }
   }
   
   private var currentOrbColor: Color {
	  switch myOrbViewModel.colorIndex {
		 case 0: return myOrbViewModel.orbColor1
		 case 1: return myOrbViewModel.orbColor2
		 case 2: return myOrbViewModel.orbColor3
		 default: return .white
	  }
   }
}
