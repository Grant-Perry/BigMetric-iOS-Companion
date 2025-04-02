import SwiftUI

public struct MetricMeta {
   public var weatherTemp: String?
   public var weatherSymbol: String?
   public var cityName: String
   public var totalTime: String
   public var startDate: Date
   public var averageSpeed: Double?
   public var stepCount: Int?
   public var energyBurned: Double?
   
   public init(weatherTemp: String? = nil,
			   weatherSymbol: String? = nil,
			   cityName: String,
			   totalTime: String,
			   startDate: Date,
			   averageSpeed: Double? = nil,
			   stepCount: Int? = nil,
			   energyBurned: Double? = nil) {
	  self.weatherTemp = weatherTemp
	  self.weatherSymbol = weatherSymbol
	  self.cityName = cityName
	  self.totalTime = totalTime
	  self.startDate = startDate
	  self.averageSpeed = averageSpeed
	  self.stepCount = stepCount
	  self.energyBurned = energyBurned
   }
   
   public init(dictionary: [String: Any]) {
	  self.weatherTemp = dictionary["weatherTemp"] as? String
	  self.weatherSymbol = dictionary["weatherSymbol"] as? String
	  self.cityName = dictionary["cityName"] as? String ?? ""
	  self.totalTime = dictionary["totalTime"] as? String ?? ""
	  self.startDate = dictionary["startDate"] as? Date ?? Date()
	  if let averageSpeedString = dictionary["averageSpeed"] as? String,
		 let averageSpeed = Double(averageSpeedString) {
		 self.averageSpeed = averageSpeed
	  } else {
		 self.averageSpeed = nil
	  }
	  if let stepCount = dictionary["stepCount"] as? Int {
		 self.stepCount = stepCount
	  } else {
		 self.stepCount = nil
	  }
	  if let energyString = dictionary["energyBurned"] as? String,
		 let energy = Double(energyString) {
		 self.energyBurned = energy
	  } else {
		 self.energyBurned = nil
	  }
   }
}
