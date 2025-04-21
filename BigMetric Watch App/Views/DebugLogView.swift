import SwiftUI

struct DebugLogView: View {
   @State private var logs: [String] = []
   let textSizeHeader: CGFloat = 30
   let textSizeLog: CGFloat = 15

   var body: some View {
	  ZStack {
		 LinearGradient(
			gradient: Gradient(
			   colors: [
				  .purple.opacity(0.8),
				  .blue.opacity(0.6),
				  .purple.opacity(0.3)
			   ]
			),
			startPoint: .topLeading,
			endPoint: .bottomTrailing
		 )
		 .ignoresSafeArea()

		 ScrollView(.vertical) {
			VStack(alignment: .leading, spacing: 18) {
			   // Header
			   HStack {
				  Image(systemName: "ladybug.slash")
					 .foregroundColor(.white)
				  Text("Debug Log")
					 .font(.system(size: textSizeHeader, weight: .bold))
					 .foregroundColor(.white)
			   }
			   .padding(.top)
			   .padding(.horizontal)

			   VStack(alignment: .leading, spacing: 12) {
				  if logs.isEmpty {
					 Text("No logs found.")
						.font(.system(size: textSizeLog))
						.foregroundColor(.white.opacity(0.5))
						.frame(maxWidth: .infinity, alignment: .center)
						.padding(.vertical, 16)
				  } else {
					 ForEach(logs.reversed(), id: \.self) { log in
						Text(log)
						   .font(.system(size: textSizeLog, design: .monospaced))
						   .foregroundColor(.white.opacity(0.85))
						   .frame(maxWidth: .infinity, alignment: .leading)
						   .padding(.vertical, 6)
						   .padding(.horizontal, 6)
						   .background(Color.white.opacity(0.08))
						   .cornerRadius(8)
					 }
				  }
			   }
			   .frame(maxWidth: .infinity)
			   .background(Color.white.opacity(0.13))
			   .cornerRadius(15)
			   .padding(.horizontal)
			   .padding(.bottom, 12)

			   Button(action: { clearLogs() }) {
				  HStack {
					 Image(systemName: "trash")
					 Text("Clear Logs")
				  }
				  .font(.system(size: 17, weight: .semibold))
				  .foregroundColor(.white)
				  .frame(maxWidth: .infinity)
				  .padding(.vertical, 12)
				  .background(
					 LinearGradient(
						gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
						startPoint: .leading,
						endPoint: .trailing
					 )
				  )
				  .cornerRadius(20)
			   }
			   .padding(.horizontal)
			   .opacity(logs.isEmpty ? 0.4 : 1)
			   .disabled(logs.isEmpty)

			   Text("\(AppConstants.appName) - ver: \(AppConstants.getVersion())")
				  .font(.system(size: 13))
				  .foregroundColor(.white.opacity(0.7))
				  .frame(maxWidth: .infinity, alignment: .center)
				  .padding(.top, 12)
			}
			.padding(.vertical)
		 }
	  }
	  .onAppear {
		 logs = UserDefaults.standard.stringArray(forKey: "logHistory") ?? []
	  }
   }

   private func clearLogs() {
	  UserDefaults.standard.removeObject(forKey: "logHistory")
	  withAnimation {
		 logs = []
	  }
   }
}
