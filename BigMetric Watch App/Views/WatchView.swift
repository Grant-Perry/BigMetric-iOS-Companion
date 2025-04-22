//  WatchView.swift
//  BigMetric Watch App
//
//  Uses animated OrbView/config from ButtonView. Orb is 30% larger.

import SwiftUI
import Orb

struct WatchView: View {
   @State private var currentTime: Date = Date()
   private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
   private let screenBounds = WKInterfaceDevice.current().screenBounds

   // Mirror the configuration logic from ButtonView
   var orbConfig: OrbConfiguration {
	  OrbConfiguration(
		 backgroundColors: [.green, .blue, .pink],
		 glowColor: .white,
		 coreGlowIntensity: 1.0, // or 0.25 for "down" state if you wish to add state
		 showWavyBlobs: true,
		 showParticles: true,
		 showGlowEffects: true,
		 showShadow: true,
		 speed: 40
	  )
   }

   var body: some View {
	  // MARK: Orb diameter follows (30% larger)
	  let scale: CGFloat = 1.45 //   xx% larger than before
	  let orbFrameWidth  = (screenBounds.width / 1.5) * 1.03 * scale
	  let orbFrameHeight = (screenBounds.height / 1.5) * 1.03 * scale
	  let orbViewWidth   = (screenBounds.width / 1.35) * 0.85 * scale
	  let orbViewHeight  = (screenBounds.height / 1.5) * 0.95 * scale

	  // MARK: Black Circle Diameter follows (unchanged)
	  let blackWidth = 0.75
	  let blackCircleWidth  = screenBounds.width * blackWidth
	  let blackCircleHeight = screenBounds.height * blackWidth

	  ZStack {
		 VStack(alignment: .center, spacing: 0) {
			ZStack {
			   Circle()
				  .fill(Color.white)
				  .frame(width: orbFrameWidth, height: orbFrameHeight)
				  .blur(radius: 23)
			}
			.overlay(
			   OrbView(configuration: orbConfig)
				  .aspectRatio(1, contentMode: .fit)
				  .frame(width: orbViewWidth, height: orbViewHeight)
			)
		 }
		 // Black center circle
		 Circle()
			.fill(Color.black).opacity(0.3)
			.frame(width: blackCircleWidth, height: blackCircleHeight)
			.shadow(color: .black.opacity(0.98), radius: 28, x: 0, y: 0)
			.overlay(
			   VStack(spacing: 0) {
				  // MARK: - Hours:Minutes
				  TimeHMLabel(date: currentTime)
					 .font(.system(size: screenBounds.width * 0.45, weight: .thin, design: .rounded))
					 .foregroundColor(.white)
					 .minimumScaleFactor(0.5)
					 .lineLimit(1)
					 .kerning(2)
					 .frame(maxWidth: .infinity)
				  TimeSecLabel(date: currentTime)
					 .frame(maxWidth: .infinity)
			   }
				  .frame(width: screenBounds.width * 0.58, height: screenBounds.height * 0.4, alignment: .center)
			)
	  }
	  .frame(width: screenBounds.width, height: screenBounds.height, alignment: .center)
	  .background(Color.black.ignoresSafeArea())
	  .onReceive(timer) { currentTime = $0 }
   }
}

// MARK: - Centered hour:minute (no leading zero hour)
struct TimeHMLabel: View {
   let date: Date

   static let formatter: DateFormatter = {
	  let df = DateFormatter()
	  df.dateFormat = "h:mm"
	  return df
   }()

   var body: some View {
	  Text(Self.formatter.string(from: date))
   }
}

// MARK: - Centered seconds label with AM/PM small and raised
struct TimeSecLabel: View {
   let date: Date

   static let secFormatter: DateFormatter = {
	  let df = DateFormatter()
	  df.dateFormat = "ss"
	  return df
   }()
   static let ampmFormatter: DateFormatter = {
	  let df = DateFormatter()
	  df.dateFormat = "a"
	  return df
   }()

   var body: some View {
	  HStack(alignment: .firstTextBaseline, spacing: 2) {
// MARK: SECONDS
		 Text(Self.secFormatter.string(from: date))
			.font(.system(size: 30, weight: .thin, design: .rounded))
			.foregroundColor(.white)
			.kerning(1.4)
			.lineLimit(1)
			.minimumScaleFactor(0.16)
			.padding(.leading)
//			.offset(x: 20)
//MARK: AM/PM
		 Text(Self.ampmFormatter.string(from: date))
			.font(.system(size: 14, weight: .light, design: .rounded))
			.foregroundColor(.white.opacity(0.86))
			.baselineOffset(6)
	  }
	  .frame(maxWidth: .infinity, alignment: .center)
	  .offset(x: 30, y: -10)
   }
}

// MARK: - PREVIEW

// Uncomment if you want a preview in Xcode:

struct WatchView_Previews: PreviewProvider {
   static var previews: some View {
	  WatchView()
		 .frame(width: 320, height: 320)
		 .previewLayout(.sizeThatFits)
   }
}
