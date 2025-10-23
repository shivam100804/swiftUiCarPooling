import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    @State private var buttonOpacity: Double = 0.0
    
    var body: some View {
        NavigationStack {
            Group {
                if isActive {
                    LoginView()
                        .transition(.opacity)
                } else {
                    splashContent
                }
            }
        }
    }
    
    private var splashContent: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.1, green: 0.3, blue: 0.7),
                                         Color(red: 0.3, green: 0.5, blue: 0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image(systemName: "car.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .scaleEffect(logoScale)
                
                Text("UniRide")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Text("Ride with trusted university peers")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, 8)
                
                Spacer()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .padding(.bottom, 30)
                    .opacity(opacity)
                
                Button(action: {
                    withAnimation {
                        isActive = true
                    }
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.7))
                        .frame(width: 200, height: 50)
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(radius: 10)
                }
                .opacity(buttonOpacity)
                .padding(.bottom, 50)
            }
            .onAppear(perform: startAnimations)
    }
}

    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.0)) {
            logoScale = 1.0
        }
        withAnimation(.easeIn(duration: 0.5).delay(0.5)) {
            opacity = 1.0
            buttonOpacity = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                isActive = true
            }
        }
    }
}
struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
