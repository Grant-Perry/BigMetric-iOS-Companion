//
//  showHeartBeat.swift
//  howFar
//
//  Exactly the same layout: swirl colorHeartBeat + BPM
//  No disclaimers
//

import SwiftUI

struct showHeartBeat: View {
   @State var unifiedWorkoutManager: UnifiedWorkoutManager

   var body: some View {
	  VStack {
		 HStack(alignment: .center) {
			colorHeartBeat()
			   .frame(width: 100)
			Spacer()
		 }
		 HStack {
			Text("\(String(format: "%.0f", unifiedWorkoutManager.heartRate))")
			   .onAppear {
				  // If you had a startHeartRate in old code, unify it here
				  // e.g. unifiedWorkoutManager.startHeartRate() if you want
			   }
			   .fontWeight(.regular)
			   .font(.system(size: 70))

			Text("BPM")
			   .font(.headline)
			   .fontWeight(.bold)
			   .foregroundColor(.red)
			   .padding(.bottom, 28.0)

			Spacer()
		 }
	  }
	  .padding()
   }
}
