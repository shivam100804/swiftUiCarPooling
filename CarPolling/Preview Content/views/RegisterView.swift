import SwiftUI

struct RegisterView: View {
    @State private var universityId: String = ""
    @State private var password: String = ""
    @State private var name: String = ""
    @State private var address: String = ""
    @State private var mobileNo: String = ""
    @State private var gender: String = ""
    @State private var dl_number: String = ""
    @State private var vehicleNo: String = ""
    @State private var isVehicleOwner: Bool = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    let backendURL = "http://localhost:8082/User/createUser"

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .red]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Carpool App")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 20)

                    TextField("University ID", text: $universityId)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    SecureField("Password", text: $password)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    TextField("Full Name", text: $name)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    TextField("Address", text: $address)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    TextField("Mobile Number", text: $mobileNo)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .keyboardType(.phonePad)

                    Picker("Gender", selection: $gender) {
                        Text("Select Gender").tag("")
                        Text("male").tag("male")
                        Text("female").tag("female")
                        Text("Other").tag("other")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                    Toggle("Are you a vehicle owner?", isOn: $isVehicleOwner)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    if isVehicleOwner {
                        TextField("Driving License Number", text: $dl_number)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)

                        TextField("Vehicle Number", text: $vehicleNo)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }

                    Button(action: registerUser) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Spacer()
                        } else {
                            Text("Register")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(isLoading)
                }
                .padding()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Registration"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func registerUser() {
        // Input validation
        guard !universityId.isEmpty, !password.isEmpty, !name.isEmpty,
              !address.isEmpty, !mobileNo.isEmpty, !gender.isEmpty else {
            alertMessage = "Please fill in all required fields."
            showAlert = true
            return
        }

        guard let mobileNoInt = Int64(mobileNo) else {
            alertMessage = "Please enter a valid mobile number."
            showAlert = true
            return
        }

        let genderLower = gender.lowercased()
        if !["male", "female", "other"].contains(genderLower) {
            alertMessage = "Invalid gender selection."
            showAlert = true
            return
        }

        isLoading = true

        let admin = isVehicleOwner ? "haveCar" : "dontHaveCar"

        let user = UserRequest(
            universityId: universityId,
            password: password,
            name: name,
            address: address,
            mobileNo: mobileNoInt,
            gender: genderLower,
            dl_number: isVehicleOwner ? dl_number : nil,
            vehicleNo: isVehicleOwner ? vehicleNo : nil,
            admin: admin
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let jsonData = try? encoder.encode(user),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Sending JSON to server:\n\(jsonString)")
        }

        guard let url = URL(string: backendURL) else {
            alertMessage = "Invalid server URL"
            showAlert = true
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try encoder.encode(user)

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    isLoading = false

                    if let error = error {
                        alertMessage = "Error: \(error.localizedDescription)"
                        showAlert = true
                        return
                    }

                    if let httpResponse = response as? HTTPURLResponse {
                        print("Status code: \(httpResponse.statusCode)")
                        if let data = data {
                            print("Response: \(String(data: data, encoding: .utf8) ?? "No data")")
                        }

                        if (200...299).contains(httpResponse.statusCode) {
                            alertMessage = "Registration successful!"
                        } else {
                            alertMessage = "Registration failed. Status: \(httpResponse.statusCode)"
                        }
                    } else {
                        alertMessage = "Invalid response from server."
                    }

                    showAlert = true
                }
            }.resume()
        } catch {
            alertMessage = "Encoding error: \(error.localizedDescription)"
            showAlert = true
            isLoading = false
        }
    }
}

struct UserRequest: Codable {
    let universityId: String
    let password: String
    let name: String
    let address: String
    let mobileNo: Int64        // Changed to Int64 here
    let gender: String         // "male", "female", "other"
    let dl_number: String?
    let vehicleNo: String?
    let admin: String          // "haveCar", "dontHaveCar"

    enum CodingKeys: String, CodingKey {
        case universityId
        case password
        case name
        case address
        case mobileNo
        case gender
        case dl_number
        case vehicleNo
        case admin
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
