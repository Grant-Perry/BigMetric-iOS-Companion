import SwiftUI
import MapKit

struct GradientMapView: UIViewRepresentable {
   var coordinates: [CLLocationCoordinate2D]
   @Binding var mapType: MKMapType

   func makeCoordinator() -> Coordinator {
	  Coordinator(self)
   }

   func makeUIView(context: Context) -> MKMapView {
	  let mapView = MKMapView()
	  mapView.delegate = context.coordinator
	  mapView.isZoomEnabled = true
	  mapView.isScrollEnabled = true
	  mapView.isRotateEnabled = true
	  mapView.mapType = mapType

	  let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
	  mapView.addOverlay(polyline)

	  if let start = coordinates.first {
		 let startAnnotation = MKPointAnnotation()
		 startAnnotation.coordinate = start
		 startAnnotation.title = "Start"
		 mapView.addAnnotation(startAnnotation)
	  }

	  if let end = coordinates.last {
		 let endAnnotation = MKPointAnnotation()
		 endAnnotation.coordinate = end
		 endAnnotation.title = "End"
		 mapView.addAnnotation(endAnnotation)
	  }

	  // Set region
	  let minLat = coordinates.map { $0.latitude }.min() ?? 0
	  let maxLat = coordinates.map { $0.latitude }.max() ?? 0
	  let minLon = coordinates.map { $0.longitude }.min() ?? 0
	  let maxLon = coordinates.map { $0.longitude }.max() ?? 0

	  let center = CLLocationCoordinate2D(
		 latitude: (minLat + maxLat) / 2,
		 longitude: (minLon + maxLon) / 2
	  )
	  let span = MKCoordinateSpan(
		 latitudeDelta: (maxLat - minLat) * 1.4,
		 longitudeDelta: (maxLon - minLon) * 1.4
	  )
	  mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: false)

	  return mapView
   }

   func updateUIView(_ mapView: MKMapView, context: Context) {
	  if mapView.mapType != mapType {
		 mapView.mapType = mapType
	  }
   }

   class Coordinator: NSObject, MKMapViewDelegate {
	  var parent: GradientMapView

	  init(_ parent: GradientMapView) {
		 self.parent = parent
	  }

	  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		 if let polyline = overlay as? MKPolyline {
			let renderer = GradientPathRenderer(polyline: polyline)
			renderer.lineWidth = 6
			return renderer
		 }
		 return MKOverlayRenderer()
	  }

	  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		 let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
		 if annotation.title == "Start" {
			annotationView.markerTintColor = .green
			annotationView.glyphImage = UIImage(systemName: "figure.walk.departure")
		 } else if annotation.title == "End" {
			annotationView.markerTintColor = .red
			annotationView.glyphImage = UIImage(systemName: "figure.walk.arrival")
		 }
		 return annotationView
	  }
   }
}
