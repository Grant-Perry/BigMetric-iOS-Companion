import SwiftUI

public struct MetricMeta {
   // Weather properties
   public var weatherTemp: String?
   public var weatherSymbol: String?
   public var cityName: String
   
   // Time and basic metrics
   public var totalTime: String
   public var startDate: Date
   public var distance: Double?
   
   // Speed metrics
   public var averageSpeed: Double?
   public var currentSpeed: Double?
   public var maxSpeed: Double?
   public var pace: Double?
   
   // Heart rate metrics
   public var averageHeartRate: Double?
   public var minHeartRate: Double?
   public var maxHeartRate: Double?
   public var heartRateZones: [Double]?
   
   // Steps and cadence
   public var stepCount: Int?
   public var stepLength: Double?
   
   // Energy metrics
   public var energyBurned: Double?
   public var activeEnergyBurned: Double?
   public var basalEnergyBurned: Double?
   
   // Running metrics
   public var runningPower: Double?
   
   // Advanced metrics
   public var elevationGain: Double?
   public var elevationLoss: Double?
   public var currentElevation: Double?
   public var cadence: Double?
   public var groundContactTime: Double?
   public var verticalOscillation: Double?
   public var strideLength: Double?
   
   public init(weatherTemp: String? = nil,
			   weatherSymbol: String? = nil,
			   cityName: String,
			   totalTime: String,
			   startDate: Date) {
	  self.weatherTemp = weatherTemp
	  self.weatherSymbol = weatherSymbol
	  self.cityName = cityName
	  self.totalTime = totalTime
	  self.startDate = startDate
	  self.distance = nil
	  self.averageSpeed = nil
	  self.currentSpeed = nil
	  self.maxSpeed = nil
	  self.pace = nil
	  self.averageHeartRate = nil
	  self.minHeartRate = nil
	  self.maxHeartRate = nil
	  self.heartRateZones = nil
	  self.stepCount = nil
	  self.stepLength = nil
	  self.energyBurned = nil
	  self.activeEnergyBurned = nil
	  self.basalEnergyBurned = nil
	  self.runningPower = nil
	  self.elevationGain = nil
	  self.elevationLoss = nil
	  self.currentElevation = nil
	  self.cadence = nil
	  self.groundContactTime = nil
	  self.verticalOscillation = nil
	  self.strideLength = nil
   }
   
   public init(dictionary: [String: Any]) {
	  self.weatherTemp = dictionary["weatherTemp"] as? String
	  self.weatherSymbol = dictionary["weatherSymbol"] as? String
	  self.cityName = dictionary["weatherCity"] as? String ?? ""
	  self.totalTime = dictionary["finalDuration"] as? String ?? ""
	  self.startDate = dictionary["startDate"] as? Date ?? Date()
	  
	  // Heart Rate
	  if let hrString = dictionary["heartRate"] as? String,
		 let hr = Double(hrString) {
		 self.averageHeartRate = hr
	  } else {
		 self.averageHeartRate = nil
	  }
	  
	  if let minHRString = dictionary["minHeartRate"] as? String,
		 let minHR = Double(minHRString) {
		 self.minHeartRate = minHR
	  } else {
		 self.minHeartRate = nil
	  }
	  
	  if let maxHRString = dictionary["maxHeartRate"] as? String,
		 let maxHR = Double(maxHRString) {
		 self.maxHeartRate = maxHR
	  } else {
		 self.maxHeartRate = nil
	  }
	  
	  // Distance and Speed
	  if let distanceString = dictionary["finalDistance"] as? String,
		 let distance = Double(distanceString) {
		 self.distance = distance
	  } else {
		 self.distance = nil
	  }
	  
	  if let avgSpeedString = dictionary["averageSpeed"] as? String,
		 let avgSpeed = Double(avgSpeedString) {
		 self.averageSpeed = avgSpeed
	  } else {
		 self.averageSpeed = nil
	  }
	  
	  // Steps and Energy
	  if let stepsString = dictionary["stepCount"] as? String,
		 let steps = Int(stepsString) {
		 self.stepCount = steps
	  } else {
		 self.stepCount = nil
	  }
	  
	  if let energyString = dictionary["energyBurned"] as? String,
		 let energy = Double(energyString) {
		 self.energyBurned = energy
	  } else {
		 self.energyBurned = nil
	  }
	  
	  // Running Dynamics
	  if let cadenceString = dictionary["cadence"] as? String,
		 let cadence = Double(cadenceString) {
		 self.cadence = cadence
	  } else {
		 self.cadence = nil
	  }
	  
	  if let gctString = dictionary["groundContactTime"] as? String,
		 let gct = Double(gctString) {
		 self.groundContactTime = gct
	  } else {
		 self.groundContactTime = nil
	  }
	  
	  if let strideString = dictionary["strideLength"] as? String,
		 let stride = Double(strideString) {
		 self.strideLength = stride
	  } else {
		 self.strideLength = nil
	  }
	  
	  if let oscString = dictionary["verticalOscillation"] as? String,
		 let osc = Double(oscString) {
		 self.verticalOscillation = osc
	  } else {
		 self.verticalOscillation = nil
	  }
	  
	  // Elevation
	  if let elevGainString = dictionary["elevationGain"] as? String,
		 let gain = Double(elevGainString) {
		 self.elevationGain = gain
	  } else {
		 self.elevationGain = nil
	  }
	  
	  if let elevLossString = dictionary["elevationLoss"] as? String,
		 let loss = Double(elevLossString) {
		 self.elevationLoss = loss
	  } else {
		 self.elevationLoss = nil
	  }
	  
	  if let currentElevString = dictionary["currentElevation"] as? String,
		 let elev = Double(currentElevString) {
		 self.currentElevation = elev
	  } else {
		 self.currentElevation = nil
	  }
   }
}
