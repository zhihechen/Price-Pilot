import SwiftUI

struct EstimationView: View {
    @EnvironmentObject var model: PredictionModel
    @Environment(\.openRouter) private var openRouter
    @Binding var navigationPath: NavigationPath
    @State private var selectedAirline = ""
    @State private var selectedSourceCity = ""
    @State private var selectedDepartTime = ""
    @State private var selectedDestinationCity = ""
    @State private var selectedArrivalTime = ""
    @State private var classType = ""
    @State private var stops = ""
    @State private var daysLeft: Int? = nil
    @State private var todaysPrice = ""
    
    // To track the submitted data
    @State private var submittedData: [String: Any] = [:]
    @State private var showAlert = false
    @State private var alertMessage = ""

    let airlines = ["Vistara", "Air_India", "Indigo", "AirAsia", "GO_FIRST", "SpiceJet"]
    let cities = ["Delhi", "Mumbai", "Bangalore", "Kolkata", "Hyderabad", "Chennai"]
    let times = ["Morning", "Early_Morning", "Evening", "Night", "Afternoon", "Late_Night"]
    let class_types = ["Economy", "Business"]
    let stops_count = ["zero", "one", "two_or_more"]

    var isFormValid: Bool {
        return !selectedAirline.isEmpty &&
               !selectedSourceCity.isEmpty &&
               !selectedDepartTime.isEmpty &&
               !selectedDestinationCity.isEmpty &&
               !selectedArrivalTime.isEmpty &&
               !classType.isEmpty &&
               !stops.isEmpty &&
               daysLeft != nil &&
               !todaysPrice.isEmpty
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Form {
                        Section("請輸入航班資訊") {
                            Picker("航空公司", selection: $selectedAirline) {
                                Text("選擇航空公司").tag("")
                                ForEach(airlines, id: \.self) { airline in
                                    Text(airline)
                                }
                            }
                            .foregroundColor(.accentColor)

                            Picker("出發城市", selection: $selectedSourceCity) {
                                Text("選擇出發城市").tag("")
                                ForEach(cities, id: \.self) { city in
                                    Text(city)
                                }
                            }
                            .foregroundColor(.accentColor)

                            Picker("出發時間", selection: $selectedDepartTime) {
                                Text("選擇出發時間").tag("")
                                ForEach(times, id: \.self) { time in
                                    Text(time)
                                }
                            }
                            .foregroundColor(.accentColor)

                            Picker("目的城市", selection: $selectedDestinationCity) {
                                Text("選擇目的城市").tag("")
                                ForEach(cities, id: \.self) { city in
                                    Text(city)
                                }
                            }
                            .foregroundColor(.accentColor)

                            Picker("抵達時間", selection: $selectedArrivalTime) {
                                Text("選擇抵達時間").tag("")
                                ForEach(times, id: \.self) { time in
                                    Text(time)
                                }
                            }
                            .foregroundColor(.accentColor)
                            
                            Picker("艙等", selection: $classType) {
                                Text("選擇艙等").tag("")
                                ForEach(class_types, id: \.self) { classType in
                                    Text(classType)
                                }
                            }
                            .foregroundColor(.accentColor)
                            
                            Picker("轉機次數", selection: $stops) {
                                Text("選擇轉機次數").tag("")
                                ForEach(stops_count, id: \.self) { stop in
                                    Text(stop)
                                }
                            }
                            .foregroundColor(.accentColor)
                            
                            if let daysLeft = daysLeft {
                                Stepper("距離出發還有: \(daysLeft)天", value: Binding(
                                    get: { daysLeft },
                                    set: { self.daysLeft = $0 }
                                ), in: 1...49)
                                .foregroundColor(.accentColor)
                            } else {
                                Button("點擊調整距離出發時間") {
                                    daysLeft = 1
                                }
                                .foregroundColor(.accentColor)
                            }

                            TextField("今日價格 (NTD)", text: $todaysPrice)
                                .keyboardType(.numberPad)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    
                    // Styled buttons container
                    VStack {
                        HStack(spacing: 20) {
                            // Clear button with modern styling
                            Button(action: {
                                selectedAirline = ""
                                selectedSourceCity = ""
                                selectedDepartTime = ""
                                selectedDestinationCity = ""
                                selectedArrivalTime = ""
                                classType = ""
                                stops = ""
                                daysLeft = nil
                                todaysPrice = ""
                            }) {
                                Text("Clear")
                                    .fontWeight(.medium)
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(UIColor.systemRed).opacity(0.9))
                                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                                    )
                                    .foregroundColor(.white)
                            }
                            
                            // Submit button with modern styling
                            Button(action: {
                                if isFormValid {
                                    submitForm()
                                } else {
                                    showAlert = true
                                    alertMessage = "Please complete all fields"
                                }
                            }) {
                                Text("Submit")
                                    .fontWeight(.medium)
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(isFormValid ? Color("AccentColor").opacity(0.9) : Color.gray.opacity(0.5))
                                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                                    )
                                    .foregroundColor(.white)
                            }
                            .disabled(!isFormValid)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                    .background(Color(UIColor.systemGroupedBackground))
                }
            }
            .navigationTitle("Price Estimation")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Form Incomplete"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func submitForm() {
        guard isFormValid, let daysLeftValue = daysLeft else { return }
        
        submittedData = [
            "airline": selectedAirline,
            "source": selectedSourceCity,
            "depart_time": selectedDepartTime,
            "destination": selectedDestinationCity,
            "arrival_time": selectedArrivalTime,
            "class": classType,
            "stops": stops,
            "days_left": daysLeftValue
        ]
        
        model.enteredPrice = Float(todaysPrice) ?? 0.0
        print("User input: \(submittedData)")
        
        navigationPath.append(Route.prediction)
        model.predictFlightPrice(
            airline: selectedAirline,
            source_city: selectedSourceCity,
            departure_time: selectedDepartTime,
            stops: stops,
            arrival_time: selectedArrivalTime,
            destination_city: selectedDestinationCity,
            travel_class: classType,
            days_left: daysLeftValue
        )
    }
}

//class PredictionModel: ObservableObject {
//    @Published var enteredPrice: Int = 0
//    @Published var predictedPrice: Float = 0
//}

#Preview {
    EstimationView(navigationPath: .constant(NavigationPath()))
        .environment(\.openRouter, .shared)
        .environmentObject(PredictionModel())
}
