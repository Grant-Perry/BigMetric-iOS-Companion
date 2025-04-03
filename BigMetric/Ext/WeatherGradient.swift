import SwiftUI

enum WeatherGradient {
   case sunny
   case cloudy
   case windy
   case rainy
   case snowy
   case partlyCloudy
   case mix
   case `default`

   init(from weatherSymbol: String?) {
	  guard let symbol = weatherSymbol else {
		 self = .default
		 return
	  }

	  switch symbol {
		 case "sun.max", "sun.min":
			self = .sunny
		 case "cloud", "cloud.fill":
			self = .cloudy
		 case "cloud.sun", "cloud.sun.fill":
			self = .partlyCloudy
		 case "wind":
			self = .windy
		 case "cloud.rain", "cloud.bolt", "cloud.bolt.rain":
			self = .rainy
		 case "snow":
			self = .snowy
		 case "cloud.sun.rain", "cloud.sun.bolt":
			self = .mix
		 default:
			self = .default
	  }
   }

   private func makeGradient(startColor: Color, endColor: Color) -> LinearGradient {
	  LinearGradient(
		 gradient: Gradient(colors: [startColor, endColor]),
		 startPoint: .top,
		 endPoint: .bottom
	  )
   }

   var gradient: LinearGradient {
	  switch self {
		 case .sunny:
			return makeGradient(startColor: Color(#colorLiteral(red: 1, green: 0.8431372549, blue: 0, alpha: 1)), endColor: Color(#colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)))
		 case .cloudy:
			return makeGradient(startColor: Color(#colorLiteral(red: 0.5176470588, green: 0.7019607843, blue: 0.8431372549, alpha: 1)), endColor: Color(#colorLiteral(red: 0.6509803922, green: 0.7843137255, blue: 0.8823529412, alpha: 1)))
		 case .windy:
			return makeGradient(startColor: Color(#colorLiteral(red: 0.2980392157, green: 0.8509803922, blue: 0.6235294118, alpha: 1)), endColor: Color(#colorLiteral(red: 0, green: 0.5607843137, blue: 0.2470588235, alpha: 1)))
		 case .rainy:
			return makeGradient(startColor: Color(#colorLiteral(red: 0.937254902, green: 0.3490196078, blue: 0.6705882353, alpha: 1)), endColor: Color(#colorLiteral(red: 0.7450980392, green: 0, blue: 0.1568627451, alpha: 1)))
		 case .snowy:
			return makeGradient(startColor: Color(#colorLiteral(red: 0.5568627715, green: 0.3529411765, blue: 0.9686274529, alpha: 1)), endColor: Color(#colorLiteral(red: 0, green: 0.2470588235, blue: 0.6196078431, alpha: 1)))
		 case .partlyCloudy:
			return makeGradient(startColor: Color(#colorLiteral(red: 1, green: 0.9254901961, blue: 0.4039215686, alpha: 1)), endColor: Color(#colorLiteral(red: 0.4588235294, green: 0.7843137255, blue: 0.9294117647, alpha: 1)))
		 case .mix:
			return makeGradient(startColor: Color(#colorLiteral(red: 0.9607843137, green: 0.6862745098, blue: 0.1333333333, alpha: 1)), endColor: Color(#colorLiteral(red: 0.2196078431, green: 0.5960784314, blue: 0.8588235294, alpha: 1)))
		 case .default:
			return makeGradient(startColor: Color(#colorLiteral(red: 0.7568627451, green: 0.6980392157, blue: 0.9568627451, alpha: 1)), endColor: Color(#colorLiteral(red: 0.6352941176, green: 0.5568627451, blue: 0.8980392157, alpha: 1)))
	  }
   }
}
