import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Image("bghex")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                // Depth overlay
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.15),
                        Color.black.opacity(0.45)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    Spacer().frame(height: 140)
                    
                    // Title Card
                    ZStack {
                        Image("Rectangle 104")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 340, height: 100)
                            .shadow(color: .black.opacity(0.6), radius: 16, y: 10)
                        
                        Text("PulseProtocol")
                            .font(.custom("Aclonica-Regular", size: 38))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Start Game Button
                    NavigationLink(destination: GameView()) {
                        Text("START GAME")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .frame(width: 280, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                            )
                    }
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
