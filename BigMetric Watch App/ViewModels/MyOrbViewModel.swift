import SwiftUI
import Observation
import Orb

@Observable
class MyOrbViewModel {
   var orbColor1: Color
   var orbColor2: Color
   var orbColor3: Color
   var colorIndex = 0

   init() {
	  let stored1 = Self.loadColor(forKey: "orbColor1Hex")
	  let stored2 = Self.loadColor(forKey: "orbColor2Hex")
	  let stored3 = Self.loadColor(forKey: "orbColor3Hex")

	  print("🎨 DP: Loaded color hexes → 1: \(UserDefaults.standard.string(forKey: "orbColor1Hex") ?? "nil"), 2: \(UserDefaults.standard.string(forKey: "orbColor2Hex") ?? "nil"), 3: \(UserDefaults.standard.string(forKey: "orbColor3Hex") ?? "nil")")
	  print("🎨 DP: Loaded color values → 1: \(String(describing: stored1)), 2: \(String(describing: stored2)), 3: \(String(describing: stored3))")

	  let storedColors = [stored1, stored2, stored3]
	  let defaultsNeeded = storedColors.allSatisfy {
		 $0 == nil || $0 == .black || $0 == .clear
	  }


	  if defaultsNeeded {
		 orbColor1 = .green
		 orbColor2 = .blue
		 orbColor3 = .pink

		 Self.saveColor(orbColor1, forKey: "orbColor1Hex")
		 Self.saveColor(orbColor2, forKey: "orbColor2Hex")
		 Self.saveColor(orbColor3, forKey: "orbColor3Hex")
	  } else {
		 orbColor1 = stored1 ?? .green
		 orbColor2 = stored2 ?? .blue
		 orbColor3 = stored3 ?? .pink
	  }
   }

   var orbConfiguration: OrbConfiguration {
	  OrbConfiguration(
		 backgroundColors: [orbColor1, orbColor2, orbColor3],
		 glowColor: .gpLtBlue,
		 coreGlowIntensity: 1.0,
		 showWavyBlobs: true,
		 showParticles: true,
		 showGlowEffects: true,
		 showShadow: true,
		 speed: 25
	  )
   }

   func updateNextColor(to newColor: Color) {
	  setColor(newColor, for: colorIndex)
	  advanceToNextColor()
   }

   func setActiveColor(_ newColor: Color) {
	  setColor(newColor, for: colorIndex)
   }

   private func setColor(_ color: Color, for index: Int) {
	  switch index {
		 case 0:
			orbColor1 = color
			Self.saveColor(color, forKey: "orbColor1Hex")
		 case 1:
			orbColor2 = color
			Self.saveColor(color, forKey: "orbColor2Hex")
		 case 2:
			orbColor3 = color
			Self.saveColor(color, forKey: "orbColor3Hex")
		 default:
			break
	  }
   }

   func advanceToNextColor() {
	  colorIndex = (colorIndex + 1) % 3
   }

   func resetToDefaultColors() {
	  setColor(.green, for: 0)
	  setColor(.blue, for: 1)
	  setColor(.pink, for: 2)
//	  setColor(.yellow, for: 0)
//	  setColor(.green, for: 1)
//	  setColor(.pink, for: 2)
   }

   private static func loadColor(forKey key: String) -> Color? {
	  guard let hex = UserDefaults.standard.string(forKey: key),
			!hex.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
		 return nil
	  }
	  return Color.fromHex(hex) ?? nil
   }

   static func saveColor(_ color: Color, forKey key: String) {
	  UserDefaults.standard.set(color.toHex(), forKey: key)
   }
}
