//
//  networking.swift
//  CarPolling
//
//  Created by Shivam Yadav on 14/05/25.
//
import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(String)
    case invalidResponse(Int)
    case decodingFailed
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let message):
            return "Request failed: \(message)"
        case .invalidResponse(let statusCode):
            return "Invalid response: HTTP \(statusCode)"
        case .decodingFailed:
            return "Failed to decode response"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}

class APIService {
    private let baseURL = "http://your-backend-url:8080/api" // Replace with your backend URL
    private var authToken: String? // Store JWT token after login
    
    func setAuthToken(_ token: String?) {
        self.authToken = token
    }
    
    func request<T: Codable>(
        endpoint: String,
        method: String,
        body: Codable? = nil,
        requiresAuth: Bool = false,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth, let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                completion(.failure(.requestFailed("Failed to encode request body")))
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse(0)))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let data = data {
                    do {
                        let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        completion(.failure(.serverError(errorResponse.error)))
                    } catch {
                        completion(.failure(.invalidResponse(httpResponse.statusCode)))
                    }
                } else {
                    completion(.failure(.invalidResponse(httpResponse.statusCode)))
                }
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidResponse(httpResponse.statusCode)))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }
    
    // Login
    func login(
        loginRequest: LoginRequest,
        completion: @escaping (Result<LoginResponse, APIError>) -> Void
    ) {
        request(
            endpoint: "users/login",
            method: "POST",
            body: loginRequest,
            completion: completion
        )
    }
    
    // Fetch user profile
    func fetchUser(
        universityId: String,
        completion: @escaping (Result<UserDto, APIError>) -> Void
    ) {
        request(
            endpoint: "users/\(universityId)",
            method: "GET",
            requiresAuth: true,
            completion: completion
        )
    }
    
    // Create booking
    func createBooking(
        booking: BookingDto,
        completion: @escaping (Result<BookingResponse, APIError>) -> Void
    ) {
        request(
            endpoint: "bookings",
            method: "POST",
            body: booking,
            requiresAuth: true,
            completion: completion
        )
    }
    
    // Fetch rides
    func fetchRides(
        completion: @escaping (Result<[RidesDto], APIError>) -> Void
    ) {
        request(
            endpoint: "rides",
            method: "GET",
            completion: completion
        )
    }
    
    // Create ride
    func createRide(
        ride: RidesDto,
        completion: @escaping (Result<RidesDto, APIError>) -> Void
    ) {
        request(
            endpoint: "rides",
            method: "POST",
            body: ride,
            requiresAuth: true,
            completion: completion
        )
    }
}
