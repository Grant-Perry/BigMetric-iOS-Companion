import SwiftUI
import MapKit
import UIKit

public class GradientPathRenderer: MKOverlayPathRenderer {
   var polyline: MKPolyline
   var colors: [CGColor]
   var showsBorder: Bool = false
   var borderColor: CGColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)

   public init(polyline: MKPolyline) {
	  self.polyline = polyline
	  // Update: Simplify to three distinct colors for clear thirds
	  self.colors = [
		 UIColor.systemGreen.cgColor,
		 UIColor.systemYellow.cgColor,
		 UIColor.systemRed.cgColor
	  ]
	  super.init(overlay: polyline)
   }

   public override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
	  guard let path = self.path else { return }
	  let baseWidth: CGFloat = self.lineWidth / zoomScale
	  if self.showsBorder {
		 context.setLineWidth(baseWidth * 2)
		 context.setLineJoin(.round)
		 context.setLineCap(.round)
		 context.addPath(path)
		 context.setStrokeColor(self.borderColor)
		 context.strokePath()
	  }

	  context.saveGState()

	  // Update: Set locations to create exact thirds
	  let locations: [CGFloat] = [0.0, 0.33, 0.66, 1.0]

	  guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
									  colors: colors as CFArray,
									  locations: locations) else { return }

	  context.addPath(path)
	  context.setLineWidth(baseWidth)
	  context.setLineJoin(.round)
	  context.setLineCap(.round)
	  context.replacePathWithStrokedPath()
	  context.clip()

	  let boundingBox = path.boundingBox
	  context.drawLinearGradient(gradient,
								 start: CGPoint(x: boundingBox.minX, y: boundingBox.minY),
								 end: CGPoint(x: boundingBox.maxX, y: boundingBox.maxY),
								 options: [])

	  context.restoreGState()
	  super.draw(mapRect, zoomScale: zoomScale, in: context)
   }

   public override func createPath() {
	  let path = CGMutablePath()
	  var pathIsEmpty = true

	  for i in 0..<self.polyline.pointCount {
		 let point = self.point(for: self.polyline.points()[i])
		 if pathIsEmpty {
			path.move(to: point)
			pathIsEmpty = false
		 } else {
			path.addLine(to: point)
		 }
	  }
	  self.path = path
   }
}
