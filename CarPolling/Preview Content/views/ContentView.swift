import SwiftUI

struct LoginView: View {
    @State private var universityId: String = ""
    @State private var password: String = ""
    @State private var isShowingRegisterView = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoggedIn = false    // State for navigation on login success

    let backendURL = "http://localhost:8082/User/login"

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.1, green: 0.3, blue: 0.7),
                                               Color(red: 0.3, green: 0.5, blue: 0.9)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer()

                    VStack {
                        Image(systemName: "car.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.white)

                        Text("UniRide")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 30)

                    VStack(spacing: 16) {
                        TextField("University ID", text: $universityId)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .autocapitalization(.none)

                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.white)

                        Button(action: loginUser) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.1, green: 0.3, blue: 0.7)))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("Login")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.7))
                                    .cornerRadius(8)
                                    .shadow(radius: 2)
                            }
                        }
                        .disabled(isLoading)
                        .padding(.top, 10)
                    }
                    .padding(.horizontal)

                    VStack {
                        Text("Don't have an account?")
                            .foregroundColor(.white.opacity(0.8))

                        Button(action: {
                            isShowingRegisterView = true
                        }) {
                            Text("Register Now")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .underline()
                        }
                    }
                    .padding(.top, 20)

                    Spacer()
                }
                .padding()
                .navigationDestination(isPresented: $isShowingRegisterView) {
                    RegisterView()  // Your existing RegisterView
                }
                .navigationDestination(isPresented: $isLoggedIn) {
                    HomeScreen()    // Navigates here on successful login
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Login"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }

    private func loginUser() {
        guard !universityId.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in all fields."
            showAlert = true
            return
        }

        isLoading = true

        guard let url = URL(string: backendURL) else {
            alertMessage = "Invalid server URL."
            showAlert = true
            isLoading = false
            return
        }

        let loginRequest = ["universityId": universityId, "password": password]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: loginRequest) else {
            alertMessage = "Error creating login request."
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
                    // Navigate to home screen on login success
                    isLoggedIn = true
                } else if httpResponse.statusCode == 401 {
                    alertMessage = "Invalid credentials. Please try again."
                    showAlert = true
                } else {
                    if let data = data,
                       let serverMsg = try? JSONDecoder().decode([String: String].self, from: data),
                       let message = serverMsg["message"] {
                        alertMessage = message
                    } else {
                        alertMessage = "Login failed with status: \(httpResponse.statusCode)"
                    }
                    showAlert = true
                }
            }
        }.resume()
    }
}

#Preview {
    LoginView()
}
