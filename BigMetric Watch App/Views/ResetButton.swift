
import SwiftUI

struct ResetButton: View {
    @State private var tapCount = 0
    @State private var resetTimer: Timer?
    let action: () -> Void
    
    var body: some View {
        Button {
            tapCount += 1
            
            // Cancel existing timer
            resetTimer?.invalidate()
            
            if tapCount == 2 {
                action()
                tapCount = 0
            } else {
                // First tap - start timer
                resetTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                    withAnimation {
                        tapCount = 0
                    }
                }
            }
        } label: {
            Image(systemName: tapCount == 1 ? "exclamationmark.triangle.fill" : "arrow.3.trianglepath")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundColor(tapCount == 1 ? .yellow : .white)
        }
        .buttonStyle(.plain)
        .frame(width: 30, height: 30)
        .background(
            LinearGradient(
                gradient: Gradient(
                    colors: [tapCount == 1 ? .red : .gpBlue, 
                            tapCount == 1 ? .orange : .gpLtBlue]
                ),
                startPoint: .bottomLeading,
                endPoint: .topLeading
            )
        )
        .clipShape(.circle)
        .onDisappear {
            resetTimer?.invalidate()
        }
    }
}
