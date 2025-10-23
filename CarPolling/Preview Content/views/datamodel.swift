//
//  datamodel.swift
//  CarPolling
//
//  Created by Shivam Yadav on 14/05/25.
//
import Foundation

// Enums for Gender and adminType
enum Gender: String, Codable {
    case male = "MALE"
    case female = "FEMALE"
    case other = "OTHER"
    // Adjust based on com.smvdu.demo.Enum.Gender
}

enum AdminType: String, Codable {
    case admin = "ADMIN"
    case user = "USER"
    // Adjust based on com.smvdu.demo.Enum.adminType
}

enum RideStatus: String, Codable {
    case active = "ACTIVE"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"
    // Adjust based on com.smvdu.demo.Enum.rideStatus
}

// PersonDto
struct PersonDto: Codable {
    let adhaar: String
    let age: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case adhaar = "adhaar"
        case age
        case name
    }
}

// BookingDto
struct BookingDto: Codable {
    let bookingId: Int
    let totalNoOfPersons: Int
    let userId: String
    let rideId: Int
    let personDtos: [PersonDto]
    
    enum CodingKeys: String, CodingKey {
        case bookingId
        case totalNoOfPersons
        case userId
        case rideId
        case personDtos
    }
}

// RidesDto
struct RidesDto: Codable {
    let date: String
    let time: String
    let fare: Int
    let pickupPoint: String
    let status: RideStatus
    let noOfVacantSeats: Int
    let dropPoint: String
    let universityId: String
    
    enum CodingKeys: String, CodingKey {
        case date
        case time
        case fare
        case pickupPoint
        case status
        case noOfVacantSeats
        case dropPoint
        case universityId = "university_id"
    }
}

// UserDto (for API requests/responses)
struct UserDto: Codable {
    let universityId: String
    let name: String
    let address: String?
    let age: Int
    let admin: AdminType
    let dlNumber: String?
    let mobileNo: Int64
    let vehicleNo: String?
    let gender: Gender
    
    enum CodingKeys: String, CodingKey {
        case universityId
        case name
        case address
        case age
        case admin
        case dlNumber = "dl_number"
        case mobileNo
        case vehicleNo
        case gender
    }
}

// Login request
struct LoginRequest: Codable {
    let universityId: String
    let password: String
}

// Login response (adjust based on your backend)
struct LoginResponse: Codable {
    let token: String
    let user: UserDto
}

// Response models
struct BookingResponse: Codable {
    let bookingId: Int
    let totalNoOfPersons: Int
    let userId: String
    let rideId: Int
    let message: String?
}

struct ErrorResponse: Codable {
    let error: String
}
