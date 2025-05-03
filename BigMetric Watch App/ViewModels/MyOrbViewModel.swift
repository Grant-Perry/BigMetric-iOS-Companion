import SwiftUI
import Observation
import Orb

@Observable
class MyOrbViewModel {
   var orbColor1: Color
   var orbColor2: Color
   var orbColor3: Color
   var fontColor: Color
   
   struct OrbColorFavorite: Codable, Equatable {
	  let top: String
	  let mid: String
	  let back: String
   }
   
   var favorites: [OrbColorFavorite?] = [nil, nil, nil]
   private var nextFavoriteSlot: Int {
	  favorites.firstIndex(where: { $0 == nil }) ?? 0
   }
   var colorIndex = 0
   
   init() {
	  let hex1 = UserDefaults.standard.string(forKey: "orbColor1Hex")
	  let hex2 = UserDefaults.standard.string(forKey: "orbColor2Hex")
	  let hex3 = UserDefaults.standard.string(forKey: "orbColor3Hex")
	  let hexFont = UserDefaults.standard.string(forKey: "fontColorHex")
	  
	  let c1 = Color.fromHex(hex1 ?? "")
	  let c2 = Color.fromHex(hex2 ?? "")
	  let c3 = Color.fromHex(hex3 ?? "")
	  let cFont = Color.fromHex(hexFont ?? "")
	  
	  let defaultsNeeded = [c1, c2, c3].allSatisfy { $0 == nil }
	  
	  if defaultsNeeded {
		 orbColor1 = .green
		 orbColor2 = .blue
		 orbColor3 = .pink
		 fontColor = .white
		 
		 Self.saveColor(orbColor1, forKey: "orbColor1Hex")
		 Self.saveColor(orbColor2, forKey: "orbColor2Hex")
		 Self.saveColor(orbColor3, forKey: "orbColor3Hex")
		 Self.saveColor(fontColor, forKey: "fontColorHex")
	  } else {
		 orbColor1 = c1 ?? .green
		 orbColor2 = c2 ?? .blue
		 orbColor3 = c3 ?? .pink
		 fontColor = cFont ?? .white
	  }
	  if let data = UserDefaults.standard.data(forKey: "orbColorFavorites"),
		 let decoded = try? JSONDecoder().decode([OrbColorFavorite?].self, from: data) {
		 favorites = decoded
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
		 case 3:
			fontColor = color
			Self.saveColor(color, forKey: "fontColorHex")
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
	  setColor(.white, for: 3)
	  //    setColor(.yellow, for: 0)
	  //    setColor(.green, for: 1)
	  //    setColor(.pink, for: 2)
   }
   
   private func persistFavorites() {
	  if let encoded = try? JSONEncoder().encode(favorites) {
		 UserDefaults.standard.set(encoded, forKey: "orbColorFavorites")
	  }
   }
   
   func saveCurrentToNextFavorite() {
	  let newFavorite = OrbColorFavorite(
		 top: orbColor1.toHex() ?? "#00FF00",
		 mid: orbColor2.toHex() ?? "#0000FF",
		 back: orbColor3.toHex() ?? "#FFC0CB"
	  )
	  favorites[nextFavoriteSlot] = newFavorite
	  persistFavorites()
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
