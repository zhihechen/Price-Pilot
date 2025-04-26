//
//  MainScreen.swift
//  NTUiOSClubLLM
//
//  Created by Jane on 2025/2/22.
//

import SwiftUI

struct MainScreen: View {
    @Environment(\.openRouter) private var openRouter
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0){
                VStack {
                    Text("PricePilot")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(Color("AccentColor"))
                        .tracking(1.2)
                        .padding(.top, 50)     // Top safe area + margin
                        .padding(.trailing, 150) // Left padding
                        .padding(.bottom, 20)  // Space before content
                   
                }
                    
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 1),
                    spacing: 16
                ) {
                    navigateButton("預測這張機票的價格", sfSymbol: "airplane", destinationRoute: .estimate)
                    
                    navigateButton("需要幫助嗎? 試試AI助理", sfSymbol: "person.crop.badge.magnifyingglass", destinationRoute: .defaultChat)
                 
                }
                .padding()
                
                
                    
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .defaultChat: DefaultChatView()
                case .estimate:
                    EstimationView(navigationPath: $path)
                case .prediction:
                        PredictionView()
                }
                
                }
            }
        }
    }


    struct TicketButtonShape: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            // Ticket dimensions and zigzag properties
            let cornerRadius: CGFloat = 20
            let zigzagHeight: CGFloat = 12
            let zigzagWidth: CGFloat = 14
            
            let zigzagAreaHeight = rect.height - cornerRadius * 2
            let cycleHeight = zigzagWidth * 2
            let numberOfCycles = Int(zigzagAreaHeight / cycleHeight)
            let extraPadding = (zigzagAreaHeight - CGFloat(numberOfCycles) * cycleHeight) / 2
            let zigzagStartY = rect.minY + cornerRadius + extraPadding

            // Top-left corner to top-right before zigzag
            path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - zigzagHeight, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius))

            // Move down to start zigzag
            path.addLine(to: CGPoint(x: rect.maxX, y: zigzagStartY))

            // Draw symmetric zigzag down the right edge
            var currentY = zigzagStartY
            for _ in 0..<numberOfCycles {
                // Zigzag out
                currentY += zigzagWidth
                path.addLine(to: CGPoint(x: rect.maxX - zigzagHeight, y: currentY))
                // Zigzag in
                currentY += zigzagWidth
                path.addLine(to: CGPoint(x: rect.maxX, y: currentY))
            }

            // Connect to bottom-right corner
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
            path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                       radius: cornerRadius,
                       startAngle: Angle(degrees: 0),
                       endAngle: Angle(degrees: 90),
                       clockwise: false)

            // Bottom edge
            path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))

            // Bottom-left corner
            path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                       radius: cornerRadius,
                       startAngle: Angle(degrees: 90),
                       endAngle: Angle(degrees: 180),
                       clockwise: false)

            // Left edge
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))

            // Top-left corner
            path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                       radius: cornerRadius,
                       startAngle: Angle(degrees: 180),
                       endAngle: Angle(degrees: 270),
                       clockwise: false)

            return path
        }
    }



    func navigateButton(_ title: String, sfSymbol: String, destinationRoute: Route) -> some View {
        NavigationLink(value: destinationRoute) {
            ZStack {
                // Ticket-shaped background with zigzag on right
                TicketButtonShape()
                    .fill(Color("AccentColor"))
                    .opacity(0.05)
                    .frame(width: 340, height: 180)
                    .overlay(
                        TicketButtonShape()
                            .stroke(Color("AccentColor"), lineWidth: 3.5) .shadow(radius: 10)
                    )
                
                VStack(spacing: 16) {
                    Image(systemName: sfSymbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text(title)
                        .font(.title2.bold())
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                // Add padding to avoid content overlapping with zigzag
                .padding(.trailing, 20)
            }
        }
    }
    
    
    
}
enum Route {
    case defaultChat
    case estimate
    case prediction
}
#Preview {
    MainScreen().environment(\.openRouter, .shared).environmentObject(PredictionModel())
}
