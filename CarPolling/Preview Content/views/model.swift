import Foundation

/// Shared parameters for ride search
struct RideSearchParameters {
    let departure: String
    let destination: String
    let time: Date
    let seats: Int
}

/// Ride model matching backend `Rides` entity with nullable fields optional
struct Ride: Identifiable, Codable {
    let id: Int                  // rideId from backend
    let date: String
    let time: String
    let fare: Int
    let pickupPoint: String
    let dropPoint: String
    let noOfVacantSeats: Int
    let carPlateNumber: String?  // Optional to handle null in DB
    let user: User?              // Optional user object

    enum CodingKeys: String, CodingKey {
        case id = "rideId"
        case date
        case time
        case fare
        case pickupPoint
        case dropPoint
        case noOfVacantSeats
        case carPlateNumber
        case user
    }
}

/// Nested User object for ride owner/driver
struct User: Codable {
    let id: Int?     // Optional because DB shows null user_id
    let name: String? // Optional, depending on backend response

    // Add CodingKeys if backend uses different JSON keys for id or name
    // enum CodingKeys: String, CodingKey {
    //     case id = "userId"
    //     case name = "userName"
    // }
}
