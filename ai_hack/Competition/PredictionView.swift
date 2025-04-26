import SwiftUI

struct PredictionView: View {
    @EnvironmentObject var model: PredictionModel
    @Environment(\.openRouter) private var openRouter

    var recommendationLevel: (text: String, color: Color, emoji: String) {
        let entered = model.enteredPrice
        let preds = [model.predictedPrice1, model.predictedPrice2, model.predictedPrice3].sorted()
        let countLower = preds.filter { entered < $0 }.count

        switch countLower {
        case 3:
            return ("強烈建議購買", Color.green, "✅")
        case 2:
            return ("建議購買", Color("AccentColor"), "⚠️")
        case 1:
            return ("不建議購買", Color.orange, "⚠️")
        default:
            return ("強烈不建議購買", Color.red, "❌")
        }
    }

    var avgPrice: Float {
        let p1 = model.predictedPrice1
        let p2 = model.predictedPrice2
        let p3 = model.predictedPrice3
        switch recommendationLevel.text {
        case "強烈建議購買", "強烈不建議購買":
            return (p1 + p2 + p3) / 3
        case "建議購買":
            let minVal = min(p1, p2, p3)
            return (p1 + p2 + p3 - minVal) / 2
        case "不建議購買":
            let maxVal = max(p1, p2, p3)
            return (p1 + p2 + p3 - maxVal) / 2
        default:
            return (p1 + p2 + p3) / 3
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Text("Prediction")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Color("AccentColor"))
                Spacer()
            }
            .padding(.horizontal)

            // Prediction Card
            VStack(spacing: 16) {
                Text("此機票的預測價格")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                let isCheaper = model.enteredPrice <= avgPrice

                VStack {
                    Text("預測價格")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("AccentColor"))
                    Text("$\(String(format: "%.0f", avgPrice)) NTD")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("AccentColor"))
                }
                .frame(maxWidth: 250, maxHeight: 100)
                .background(Color("AccentColor").opacity(0.1))
                .cornerRadius(12)
                .padding(.bottom, 30)

                VStack(alignment: .leading, spacing: 12) {
                    Text("您輸入之目前價格")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text("$\(String(format: "%.0f", model.enteredPrice)) NTD")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    ZStack(alignment: .leading) {
                        // 4-level scale background
                        HStack(spacing: 0) {
                            Color.green.opacity(0.5)     // 強烈建議購買
                            Color.yellow.opacity(0.5)    // 建議購買
                            Color.orange.opacity(0.5)    // 不建議購買
                            Color.red.opacity(0.5)       // 強烈不建議購買
                        }
                        .frame(width: 300,height: 20)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                        .padding()

                        // Marker position by recommendation level
                        let scaleWidth = UIScreen.main.bounds.width * 0.9
                        let sectionWidth = scaleWidth / 4
                        let positionIndex: Int = {
                            switch recommendationLevel.text {
                            case "強烈建議購買": return 0
                            case "建議購買": return 1
                            case "不建議購買": return 2
                            default: return 3 // 強烈不建議購買
                            }
                        }()
                        let position = CGFloat(positionIndex) * sectionWidth + sectionWidth / 2

                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundColor(recommendationLevel.color)
                            .overlay(Image(systemName: "arrowtriangle.down.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                        .offset(y: 6))
                            .offset(x: position - 10, y: -4)
                            .animation(.easeInOut, value: model.enteredPrice)
                    }
                    .frame(height: 80)
                }

                // Recommendation Capsule
                HStack {
                    Text("\(recommendationLevel.emoji) \(recommendationLevel.text)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(recommendationLevel.color)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(recommendationLevel.color.opacity(0.3))
                        .clipShape(Capsule())
                        //.shadow(radius: 5)
                }
                .padding(.top, 10)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(LinearGradient(colors: [Color.white, Color("BackgroundColor").opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top)
        .background(Color("BackgroundColor").edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    PredictionView().environmentObject(PredictionModel())
}

