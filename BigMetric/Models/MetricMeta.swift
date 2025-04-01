import SwiftUI

public struct MetricMeta {
   public var weatherTemp: String?
   public var weatherSymbol: String?
   public var cityName: String
   public var totalTime: String
   public var startDate: Date
   public var averageSpeed: Double?

   public init(weatherTemp: String? = nil,
			   weatherSymbol: String? = nil,
			   cityName: String,
			   totalTime: String,
			   startDate: Date,
			   averageSpeed: Double? = nil) {
	  self.weatherTemp = weatherTemp
	  self.weatherSymbol = weatherSymbol
	  self.cityName = cityName
	  self.totalTime = totalTime
	  self.startDate = startDate
	  self.averageSpeed = averageSpeed
   }
}
