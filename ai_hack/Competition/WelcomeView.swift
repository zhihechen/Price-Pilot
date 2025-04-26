import SwiftUI

struct WelcomeView: View {
    @Environment(\.openRouter) private var openRouter
    @Binding var showMain: Bool

    var body: some View {
        ZStack {
            Color("AccentColor")
                .opacity(0.05)
                .ignoresSafeArea()

            VStack {
                Spacer()
                HStack (spacing: 8) {
                    Text("PRICE")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                    Image(systemName: "airplane")
                          .font(.title)
                          .foregroundColor(.accentColor)
                    Text("PILOT")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                }
                
                .padding()
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 30)
                
                
        
                Text("伺「機」而動：機票 AI 預測助理")
                    .font(.callout)
                    .foregroundColor(Color("AccentColor"))
                    .padding(.bottom, 100)
                
                FakeBarcode()
                Text("點擊空白處以開始預測機票價格")
                    .font(.callout)
                    .foregroundColor(Color("AccentColor"))
                    .padding(.top, 30)
                Spacer()
                
            }.background(
                TicketShape()
                    .stroke(Color.accentColor, lineWidth: 4)
                    .background(
                        TicketShape()
                            .fill(Color.white)
                    )
            
            ).padding()
                .padding(.bottom, -15)
                .onTapGesture {
                    withAnimation {
                        showMain = true
                    }
                }
        }
    }
}
struct FakeBarcode: View {
    let bars: [CGFloat] = [2, 4, 1, 6, 2, 1, 5, 1, 3, 1, 3, 2, 5, 3, 5, 6, 3, 5, 7, 2, 4, 6, 4 ,1, 5,  4, 6, 3, 5, 7, 2, 4] // Simulated bar widths

    var body: some View {
        HStack(spacing: 5) {
            ForEach(bars.indices, id: \.self) { index in
                Rectangle()
                    .fill(Color("AccentColor"))
                    .frame(width: bars[index], height: 90)
            }
        }
        .padding(.top)
    }
}

struct TicketShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Ticket dimensions and properties
        let cornerRadius: CGFloat = 8
        let zigzagHeight: CGFloat = 10  // Height of zigzag pattern
        let zigzagWidth: CGFloat = 15   // Width of each zigzag segment
        
        // Create path with rounded corners at the top
        path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
        
        // Top edge
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        
        // Top right corner
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
                   radius: cornerRadius,
                   startAngle: Angle(degrees: -90),
                   endAngle: Angle(degrees: 0),
                   clockwise: false)
        
        // Right edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - zigzagHeight))
        
        // Bottom zigzag edge
        var currentX: CGFloat = rect.maxX
        var goingDown = true
        
        // Start the zigzag at the right edge
        path.move(to: CGPoint(x: currentX, y: rect.maxY - zigzagHeight))
        
        // Create zigzag pattern
        while currentX > rect.minX {
            let nextX = max(currentX - zigzagWidth, rect.minX)
            let nextY = goingDown ? rect.maxY : rect.maxY - zigzagHeight
            
            path.addLine(to: CGPoint(x: nextX, y: nextY))
            
            currentX = nextX
            goingDown.toggle()
        }
        
        // Ensure we end at the left edge
        if currentX == rect.minX {
            let lastY = goingDown ? rect.maxY : rect.maxY - zigzagHeight
            path.addLine(to: CGPoint(x: rect.minX, y: lastY))
        }
        
        // Left edge
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        
        // Top left corner
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                   radius: cornerRadius,
                   startAngle: Angle(degrees: 180),
                   endAngle: Angle(degrees: 270),
                   clockwise: false)
        
        return path
    }
}

#Preview {
    WelcomeView(showMain: .constant(false)).environment(\.openRouter, .shared).environmentObject(PredictionModel())
}
