import SwiftUI

struct WorkoutErrorView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.system(size: 17))
            .foregroundColor(.red)
            .frame(maxWidth: .infinity, minHeight: 200)
            .background(Color.red.opacity(0.1))
            .cornerRadius(16)
    }
}