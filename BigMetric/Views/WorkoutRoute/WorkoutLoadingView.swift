import SwiftUI

struct WorkoutLoadingView: View {
    var body: some View {
        ProgressView("Loading workout data...")
            .progressViewStyle(CircularProgressViewStyle())
            .frame(maxWidth: .infinity, minHeight: 200)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
    }
}