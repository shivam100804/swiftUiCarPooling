import SwiftUI

struct RegisterView: View {
    @State private var universityId: String = ""
    @State private var password: String = ""
    @State private var name: String = ""
    @State private var address: String = ""
    @State private var age: String = ""
    @State private var dl_number: String = ""
    @State private var vehicleNo: String = ""
    @State private var isVehicleOwner: Bool = false
    
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let backendURL = "http://localhost:8080/User/createUser"
    
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
                    
                    // University ID
                    TextField("University ID", text: $universityId)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    // Password
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    // Name
                    TextField("Full Name", text: $name)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    // Address
                    TextField("Address", text: $address)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    // Age
                    TextField("Age", text: $age)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .keyboardType(.numberPad)
                    
                    // Vehicle owner toggle
                    Toggle("Are you a vehicle owner?", isOn: $isVehicleOwner)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    if isVehicleOwner {
                        // dl_number (with underscore)
                        TextField("Driving License Number", text: $dl_number)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        // vehicleNo (camelCase)
                        TextField("Vehicle Number", text: $vehicleNo)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Register button
                    Button(action: registerUser) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
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
        guard !universityId.isEmpty, !password.isEmpty, !name.isEmpty,
              !address.isEmpty, !age.isEmpty else {
            alertMessage = "Please fill in all required fields."
            showAlert = true
            return
        }
        
        guard let ageInt = Int(age) else {
            alertMessage = "Please enter a valid age."
            showAlert = true
            return
        }
        
        isLoading = true
        
        // Create request object that matches your Java entity exactly
        let user = UserRequest(
            universityId: universityId,
            password: password,
            name: name,
            address: address,
            age: ageInt,
            dl_number: isVehicleOwner ? dl_number : nil,
            vehicleNo: isVehicleOwner ? vehicleNo : nil
        )
        
        // Debug print the JSON
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
                    }
                    
                    alertMessage = "Registration completed" // Will show actual status in alert
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

// Exactly matches your Java User entity
struct UserRequest: Codable {
    let universityId: String
    let password: String
    let name: String
    let address: String
    let age: Int
    let dl_number: String?  // Note the underscore
    let vehicleNo: String?  // Note camelCase
    
    // No CodingKeys needed since we're using exact names
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
