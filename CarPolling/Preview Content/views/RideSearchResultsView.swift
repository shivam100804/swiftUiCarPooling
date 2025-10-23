import SwiftUI
import Foundation // For urlPathAllowed character set

struct RideSearchResultsView: View {
    let searchParams: RideSearchParameters

    @State private var availableRides: [Ride] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    let backendBaseURL = "http://localhost:8082"

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading rides...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if availableRides.isEmpty {
                Text("No rides available from \(searchParams.departure) to \(searchParams.destination).")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Available Rides")
                            .font(.title)
                            .bold()
                            .padding(.top)

                        Text("From \(searchParams.departure) to \(searchParams.destination)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        ForEach(availableRides) { ride in
                            RideBlock(ride: ride)
                        }
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
            }
        }
        .navigationTitle("Search Results")
        .onAppear(perform: fetchRides)
    }

    private func fetchRides() {
        isLoading = true
        errorMessage = nil

        guard let dropPointEncoded = searchParams.destination.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "\(backendBaseURL)/Rides/ridesAvailableAt/\(dropPointEncoded)") else {
            errorMessage = "Invalid destination URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    errorMessage = "Failed to fetch rides: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode),
                      let data = data else {
                    errorMessage = "Invalid server response"
                    return
                }

                // For debugging: print raw json string
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Received JSON:", jsonString)
                }

                do {
                    availableRides = try JSONDecoder().decode([Ride].self, from: data)
                } catch {
                    print("Decoding error:", error)
                    errorMessage = "Failed to parse rides data: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

struct RideBlock: View {
    let ride: Ride

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(ride.user?.name ?? "Unknown Rider")
                .font(.headline)

            HStack {
                Image(systemName: "car.fill")
                Text("\(ride.pickupPoint) → \(ride.dropPoint)")
            }

            HStack {
                Image(systemName: "calendar")
                Text(ride.date)

                Image(systemName: "clock")
                    .padding(.leading)
                Text(ride.time)
            }

            HStack {
                Image(systemName: "dollarsign.circle")
                Text("\(ride.fare)")

                Image(systemName: "person.2.fill")
                    .padding(.leading)
                Text("\(ride.noOfVacantSeats) seat\(ride.noOfVacantSeats == 1 ? "" : "s") available")
            }

            Text("Car Plate: \(ride.carPlateNumber ?? "N/A")")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button(action: {
                // TODO: Add action to book this ride
            }) {
                Text("Book Ride")
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct RideSearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        RideSearchResultsView(searchParams: RideSearchParameters(
            departure: "University Gate 1",
            destination: "University Gate 2",
            time: Date(),
            seats: 2
        ))
    }
}
