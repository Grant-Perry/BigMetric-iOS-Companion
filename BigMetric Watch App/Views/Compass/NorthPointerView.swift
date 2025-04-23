//
//  NorthPointerView.swift
//  BigMetric Watch App
//

import SwiftUI

/// A fixed red triangle pointer that always points North, centered at the top of the compass.
struct NorthPointerView: View {
   @State private var rotateTicks: Bool = true
   @State var screenBounds = WKInterfaceDevice.current().screenBounds
   @StateObject private var compassManager = CompassLMManager()

   var body: some View {
	  VStack {
		 ZStack {
			Image("greenArrow")
			   .resizable()
			   .scaledToFit()
			   .frame(width: 50, height: 110)
			   .foregroundColor(.green)
			   .rotationEffect(.degrees(rotateTicks ? 0 : compassManager.course))
			   .opacity(0.95)
			   .scaleEffect(1.0)
			   .animation(.spring(response: 0.5), value: rotateTicks)

			// MARK: Use CardinalDirection to get direction initial
			Text(CardinalDirection.closestDirection(to: compassManager.course).rawValue)
			   .font(.subheadline)
			   .foregroundColor(.white)
			   .bold()
			   .shadow(radius: 15)
			   .padding(8)
		 }
		 .shadow(radius: 33)
		 Spacer()
	  }
	  .padding(.top, 32)
	  .onAppear {
		 compassManager.startUpdates()
	  }
	  .onDisappear {
		 compassManager.stopUpdates()
	  }
   }
}

#Preview {
   NorthPointerView()
	  .frame(width: 184, height: 224)
	  .background(Color.black)
}
