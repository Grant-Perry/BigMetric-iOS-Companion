import CoreLocation
import SwiftUI

class CompassLMManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var heading: String = "N"
    @Published var course: Double = 0.0
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.headingFilter = 5
        locationManager.headingOrientation = .portrait
    }
    
    func startUpdates() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func stopUpdates() {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        course = newHeading.trueHeading
        heading = course.toCardinalDirection()
    }
}

// Helper extension for converting degrees to cardinal directions
private extension Double {
    func toCardinalDirection() -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((self + 22.5).truncatingRemainder(dividingBy: 360) / 45.0)
        return directions[index]
    }
}