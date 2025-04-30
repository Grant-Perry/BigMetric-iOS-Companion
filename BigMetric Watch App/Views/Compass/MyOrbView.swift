import SwiftUI

struct MyOrbView: View {
   @Environment(MyOrbViewModel.self) private var myOrbViewModel

   var body: some View {
	  ZStack {
		 Circle()
			.fill(Color.white.opacity(0.2))
			.frame(width: 80, height: 80)
			.blur(radius: 10)

		 Circle()
			.fill(
			   RadialGradient(
				  gradient: Gradient(colors: [
					 myOrbViewModel.orbColor1,
					 myOrbViewModel.orbColor2,
					 myOrbViewModel.orbColor3
				  ]),
				  center: .center,
				  startRadius: 5,
				  endRadius: 40
			   )
			)
			.frame(width: 80, height: 80)
			.shadow(color: .white.opacity(0.2), radius: 8)
			.overlay(
			   Circle()
				  .stroke(Color.white.opacity(0.1), lineWidth: 1)
			)
	  }
   }
}

#Preview {
   MyOrbView()
	  .environment(MyOrbViewModel())
	  .padding()
	  .background(Color.black)
}
