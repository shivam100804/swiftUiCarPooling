import SwiftUI

struct CreateRideView: View {
    @State private var carPlateNumber = ""
    @State private var universityId = ""
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var date = Date()
    @State private var time = Date()
    @State private var fare = ""
    @State private var pickupPoint: PickupGate = .gate1
    @State private var dropPoint = ""
    @State private var noOfVacantSeats = 1

    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    enum PickupGate: String, CaseIterable {
        case gate1 = "University Gate 1"
        case gate2 = "University Gate 2"

        var id: String { self.rawValue }
    }

    let backendURL = "http://localhost:8082/Rides/create_ride"

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Create New Ride")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.top, 20)

                        // Driver Information Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Driver Information")
                                .font(.headline)
                                .foregroundColor(.white)

                            TextField("University ID", text: $universityId)
                                .textFieldStyle(CreateRideTextFieldStyle())

                            TextField("Car Plate Number", text: $carPlateNumber)
                                .textFieldStyle(CreateRideTextFieldStyle())

                            TextField("Your Name", text: $name)
                                .textFieldStyle(CreateRideTextFieldStyle())

                            TextField("Phone Number", text: $phoneNumber)
                                .keyboardType(.phonePad)
                                .textFieldStyle(CreateRideTextFieldStyle())
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)

                        // Ride Details Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ride Details")
                                .font(.headline)
                                .foregroundColor(.white)

                            DatePicker("Date", selection: $date, displayedComponents: .date)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                                .accentColor(.white)

                            DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                                .accentColor(.white)

                            TextField("Fare Amount", text: $fare)
                                .keyboardType(.numberPad)
                                .textFieldStyle(CreateRideTextFieldStyle())

                            Picker("Pickup Gate", selection: $pickupPoint) {
                                ForEach(PickupGate.allCases, id: \.self) { gate in
                                    Text(gate.rawValue).tag(gate)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                            .accentColor(.white)

                            TextField("Destination", text: $dropPoint)
                                .textFieldStyle(CreateRideTextFieldStyle())

                            // New: Number of Vacant Seats Stepper
                            VStack(alignment: .leading) {
                                Text("Number of Vacant Seats")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Stepper(value: $noOfVacantSeats, in: 1...10) {
                                    Text("\(noOfVacantSeats)")
                                        .foregroundColor(.white)
                                        .font(.title3)
                                }
                                .padding(.top, 4)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 80) // Extra padding for the fixed button
                }

                // Fixed Create Ride Button at bottom
                VStack {
                    Button(action: createRide) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Create Ride")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .disabled(isLoading)
                }
                .background(Color.clear)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Create Ride"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func createRide() {
        guard validateFields() else { return }

        isLoading = true

        // Formatting date and time strings compatible with backend expectations
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateString = dateFormatter.string(from: date)

        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let timeString = dateFormatter.string(from: time)

        guard let fareValue = Int(fare) else {
            alertMessage = "Fare amount must be a valid number"
            showAlert = true
            isLoading = false
            return
        }

        // Prepare dictionary for JSON body including universityId and noOfVacantSeats
        let rideDict: [String: Any] = [
            "universityId": universityId,
            "carPlateNumber": carPlateNumber,
            "driverName": name,
            "phoneNumber": phoneNumber,
            "date": dateString,
            "time": timeString,
            "fare": fareValue,
            "pickupPoint": pickupPoint.rawValue,
            "dropPoint": dropPoint,
            "noOfVacantSeats": noOfVacantSeats   // <-- Added here
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: rideDict, options: [])

            guard let url = URL(string: backendURL) else {
                alertMessage = "Invalid server URL"
                showAlert = true
                isLoading = false
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    isLoading = false

                    if let error = error {
                        alertMessage = "Network error: \(error.localizedDescription)"
                        showAlert = true
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse else {
                        alertMessage = "Invalid response from server."
                        showAlert = true
                        return
                    }

                    if (200...299).contains(httpResponse.statusCode) {
                        alertMessage = "Ride created successfully!"
                        clearFields()
                    } else {
                        alertMessage = "Failed to create ride. Status: \(httpResponse.statusCode)"
                    }

                    showAlert = true
                }
            }
            .resume()
        } catch {
            alertMessage = "Failed to encode ride data: \(error.localizedDescription)"
            showAlert = true
            isLoading = false
        }
    }

    private func clearFields() {
        universityId = ""
        carPlateNumber = ""
        name = ""
        phoneNumber = ""
        fare = ""
        dropPoint = ""
        noOfVacantSeats = 1
        date = Date()
        time = Date()
        pickupPoint = .gate1
    }

    private func validateFields() -> Bool {
        guard !universityId.isEmpty,
              !carPlateNumber.isEmpty,
              !name.isEmpty,
              !phoneNumber.isEmpty,
              !fare.isEmpty,
              !dropPoint.isEmpty else {
            alertMessage = "Please fill in all required fields"
            showAlert = true
            return false
        }

        guard let fareValue = Int(fare), fareValue > 0 else {
            alertMessage = "Please enter a valid fare amount"
            showAlert = true
            return false
        }

        return true
    }
}

struct CreateRideTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(8)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
    }
}

#Preview {
    CreateRideView()
}
