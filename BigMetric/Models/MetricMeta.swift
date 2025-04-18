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
	  self.cityName = dictionary["cityName"] as? String ?? ""
	  self.totalTime = dictionary["totalTime"] as? String ?? ""
	  self.startDate = dictionary["startDate"] as? Date ?? Date()
	  if let distanceString = dictionary["distance"] as? String,
		 let distance = Double(distanceString) {
		 self.distance = distance
	  } else {
		 self.distance = nil
	  }
	  if let averageSpeedString = dictionary["averageSpeed"] as? String,
		 let averageSpeed = Double(averageSpeedString) {
		 self.averageSpeed = averageSpeed
	  } else {
		 self.averageSpeed = nil
	  }
	  if let currentSpeedString = dictionary["currentSpeed"] as? String,
		 let currentSpeed = Double(currentSpeedString) {
		 self.currentSpeed = currentSpeed
	  } else {
		 self.currentSpeed = nil
	  }
	  if let maxSpeedString = dictionary["maxSpeed"] as? String,
		 let maxSpeed = Double(maxSpeedString) {
		 self.maxSpeed = maxSpeed
	  } else {
		 self.maxSpeed = nil
	  }
	  if let paceString = dictionary["pace"] as? String,
		 let pace = Double(paceString) {
		 self.pace = pace
	  } else {
		 self.pace = nil
	  }
	  if let averageHeartRateString = dictionary["averageHeartRate"] as? String,
		 let averageHeartRate = Double(averageHeartRateString) {
		 self.averageHeartRate = averageHeartRate
	  } else {
		 self.averageHeartRate = nil
	  }
	  if let minHeartRateString = dictionary["minHeartRate"] as? String,
		 let minHeartRate = Double(minHeartRateString) {
		 self.minHeartRate = minHeartRate
	  } else {
		 self.minHeartRate = nil
	  }
	  if let maxHeartRateString = dictionary["maxHeartRate"] as? String,
		 let maxHeartRate = Double(maxHeartRateString) {
		 self.maxHeartRate = maxHeartRate
	  } else {
		 self.maxHeartRate = nil
	  }
	  if let heartRateZones = dictionary["heartRateZones"] as? [Double] {
		 self.heartRateZones = heartRateZones
	  } else {
		 self.heartRateZones = nil
	  }
	  if let stepCount = dictionary["stepCount"] as? Int {
		 self.stepCount = stepCount
	  } else {
		 self.stepCount = nil
	  }
	  if let stepLengthString = dictionary["stepLength"] as? String,
		 let stepLength = Double(stepLengthString) {
		 self.stepLength = stepLength
	  } else {
		 self.stepLength = nil
	  }
	  if let energyString = dictionary["energyBurned"] as? String,
		 let energy = Double(energyString) {
		 self.energyBurned = energy
	  } else {
		 self.energyBurned = nil
	  }
	  if let activeEnergyString = dictionary["activeEnergyBurned"] as? String,
		 let activeEnergy = Double(activeEnergyString) {
		 self.activeEnergyBurned = activeEnergy
	  } else {
		 self.activeEnergyBurned = nil
	  }
	  if let basalEnergyString = dictionary["basalEnergyBurned"] as? String,
		 let basalEnergy = Double(basalEnergyString) {
		 self.basalEnergyBurned = basalEnergy
	  } else {
		 self.basalEnergyBurned = nil
	  }
	  if let runningPowerString = dictionary["runningPower"] as? String,
		 let runningPower = Double(runningPowerString) {
		 self.runningPower = runningPower
	  } else {
		 self.runningPower = nil
	  }
	  if let elevationGainString = dictionary["elevationGain"] as? String,
		 let elevationGain = Double(elevationGainString) {
		 self.elevationGain = elevationGain
	  } else {
		 self.elevationGain = nil
	  }
	  if let elevationLossString = dictionary["elevationLoss"] as? String,
		 let elevationLoss = Double(elevationLossString) {
		 self.elevationLoss = elevationLoss
	  } else {
		 self.elevationLoss = nil
	  }
	  if let currentElevationString = dictionary["currentElevation"] as? String,
		 let currentElevation = Double(currentElevationString) {
		 self.currentElevation = currentElevation
	  } else {
		 self.currentElevation = nil
	  }
	  if let cadenceString = dictionary["cadence"] as? String,
		 let cadence = Double(cadenceString) {
		 self.cadence = cadence
	  } else {
		 self.cadence = nil
	  }
	  if let groundContactTimeString = dictionary["groundContactTime"] as? String,
		 let groundContactTime = Double(groundContactTimeString) {
		 self.groundContactTime = groundContactTime
	  } else {
		 self.groundContactTime = nil
	  }
	  if let verticalOscillationString = dictionary["verticalOscillation"] as? String,
		 let verticalOscillation = Double(verticalOscillationString) {
		 self.verticalOscillation = verticalOscillation
	  } else {
		 self.verticalOscillation = nil
	  }
	  if let strideLengthString = dictionary["strideLength"] as? String,
		 let strideLength = Double(strideLengthString) {
		 self.strideLength = strideLength
	  } else {
		 self.strideLength = nil
	  }
   }
}
