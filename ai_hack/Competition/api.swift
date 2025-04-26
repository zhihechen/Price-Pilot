import Foundation

struct PredictRequest: Codable {
    let airline: String
    let source_city: String
    let departure_time: String
    let stops: String
    let arrival_time: String
    let destination_city: String
    let travel_class: String
    let days_left: Int

    enum CodingKeys: String, CodingKey {
        case airline, source_city, departure_time, stops, arrival_time, destination_city, travel_class = "class", days_left
    }
}

struct PredictResponse: Codable {
    let rf_price: Double
    let gbr_price: Double
    let xgb_price: Double
}

class PredictionModel: ObservableObject {
    @Published var enteredPrice: Float = 0.0
    @Published var predictedPrice1: Float = 0.0
    @Published var predictedPrice2: Float = 0.0
    @Published var predictedPrice3: Float = 0.0

    func predictFlightPrice(
        airline: String,
        source_city: String,
        departure_time: String,
        stops: String,
        arrival_time: String,
        destination_city: String,
        travel_class: String,
        days_left: Int
    ) {
        guard let url = URL(string: "http://10.104.0.151:8000/predict") else {
            print("Invalid URL")
            return
        }

        let requestBody = PredictRequest(
            airline: airline,
            source_city: source_city,
            departure_time: departure_time,
            stops: stops,
            arrival_time: arrival_time,
            destination_city: destination_city,
            travel_class: travel_class,
            days_left: days_left
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
        } catch {
            print("Failed to encode JSON: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let data = data else {
                print("No data")
                return
            }

            do {
                let predictResponse = try JSONDecoder().decode(PredictResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.predictedPrice1 = Float(predictResponse.rf_price)
                    self?.predictedPrice2 = Float(predictResponse.gbr_price)
                    self?.predictedPrice3 = Float(predictResponse.xgb_price)
                }
            } catch {
                print("Failed to decode response: \(error)")
            }
        }

        task.resume()
    }
}

