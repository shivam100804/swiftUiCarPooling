//
//  CreateRide.swift
//  CarPolling
//
//  Created by Shivam Yadav on 27/03/25.
//
import SwiftUI

struct CreateRideView: View {
    @State private var date: String = ""
    @State private var time: String = ""
    @State private var fare: String = ""
    @State private var pickupPoint: String = ""
    @State private var dropPoint: String = ""
    @State private var status: RideStatus = .available
    
    enum RideStatus: String, CaseIterable {
        case available = "AVAILABLE"
        case booked = "BOOKED"
        case completed = "COMPLETED"
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                         startPoint: .topLeading,
                         endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Create New Ride")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 20)
                    
                    // Date Picker
                    TextField("Date (YYYY-MM-DD)", text: $date)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .keyboardType(.numbersAndPunctuation)
                    
                    // Time Picker
                    TextField("Time (HH:MM)", text: $time)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .keyboardType(.numbersAndPunctuation)
                    
                    // Fare
                    TextField("Fare", text: $fare)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .keyboardType(.numberPad)
                    
                    // Pickup Point
                    TextField("Pickup Point", text: $pickupPoint)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    // Drop Point
                    TextField("Drop Point", text: $dropPoint)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
//                    // Status Picker
//                    Picker("Status", selection: $status) {
//                        ForEach(RideStatus.allCases, id: \.self) { status in
//                            Text(status.rawValue).tag(status)
//                        }
//                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    Button(action: {
                        createRide()
                    }) {
                        Text("Create Ride")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    private func createRide() {
        guard !date.isEmpty,
              !time.isEmpty,
              !fare.isEmpty,
              !pickupPoint.isEmpty,
              !dropPoint.isEmpty else {
            print("Please fill in all required fields.")
            return
        }
        
        guard let fareValue = Int(fare) else {
            print("Fare must be a valid number")
            return
        }
        
        print("Ride Creation Details:")
        print("Date: \(date)")
        print("Time: \(time)")
        print("Fare: \(fareValue)")
        print("Pickup: \(pickupPoint)")
        print("Drop: \(dropPoint)")
        print("Status: \(status.rawValue)")
        
        // Here you would make API call to your Spring Boot backend
        // using URLSession or similar networking code
    }
}

#Preview {
    CreateRideView()
}
