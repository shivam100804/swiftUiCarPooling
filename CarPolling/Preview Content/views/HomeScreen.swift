import SwiftUI

struct HomeScreen: View {
    @State private var pickupPoint = ""
    @State private var dropPoint = ""
    @State private var time = Date()
    @State private var noOfVacantSeats = 1
    @State private var showSearchResults = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchRideSection
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding()

                appMotoSection
                    .padding(.horizontal)
                    .frame(maxHeight: .infinity)

                createRideButton
                    .padding(.bottom, 30)
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.1, green: 0.3, blue: 0.7),
                                                           Color(red: 0.3, green: 0.5, blue: 0.9)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            )
            .navigationDestination(isPresented: $showSearchResults) {
                RideSearchResultsView(searchParams: RideSearchParameters(
                    departure: pickupPoint,
                    destination: dropPoint,
                    time: time,
                    seats: noOfVacantSeats
                ))
            }
        }
    }

    private var searchRideSection: some View {
        VStack(spacing: 16) {
            Text("Find Your Ride")
                .font(.title2)
                .bold()
                .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.7))

            TextField("From", text: $pickupPoint)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("To", text: $dropPoint)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            DatePicker("Departure Time", selection: $time, displayedComponents: .hourAndMinute)
                .foregroundColor(.primary)

            Stepper("Seats Needed: \(noOfVacantSeats)", value: $noOfVacantSeats, in: 1...4)

            Button(action: {
                showSearchResults = true
            }) {
                Text("Search Rides")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.1, green: 0.3, blue: 0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }

    private var appMotoSection: some View {
        VStack {
            Image(systemName: "car.2.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.white)

            Text("UniRide")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                .padding(.top, 10)

            Text("Connecting University Students for Smarter Commutes")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.top, 8)

            Text("Save money, reduce traffic, and make new friends on your daily commute!")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 16)
                .padding(.horizontal, 20)
        }
    }

    private var createRideButton: some View {
        NavigationLink(destination: CreateRideView()) {
            Text("Create a Ride")
                .font(.headline)
                .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.7))
                .frame(width: 200, height: 50)
                .background(Color.white)
                .cornerRadius(25)
                .shadow(radius: 5)
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
