//
// ShaadiModel.swift
// Cityflo
//
// Created by Anshul Gupta on 03/08/24.
// Copyright © Cityflo. All rights reserved.
//


import Foundation

struct Matrimonial: Codable {
    var results: [Users]?
    var info: ApiInfo?
}

struct ApiInfo: Codable {
    var seed: String?
    var results: Int?
    var page: Int?
    var version: String?
}

struct Users: Codable {
    var gender: String?
    var name: Name?
    var location: Location?
    var email: String?
    var login: LoginDetails?
    var dob: Dob?
    var registered: Registered?
    var phone: String?
    var cell: String?
    var id: Id?
    var picture: Picture?
    var nat: String?
}

struct Picture: Codable {
    var large: String?
    var medium: String?
    var thumbnail: String?
}

struct Id: Codable {
    var name: String?
    var value: String?
}

struct Registered: Codable {
    var date: String?
    var age: Int?
}

struct Dob: Codable {
    var date: String?
    var age: Int?
}

struct Name: Codable {
    var title: String?
    var first: String?
    var last: String?
}

struct Location: Codable {
    var street: Street?
    var city: String?
    var state: String?
    var country: String?
    //var postcode: String?
    var coordinates: Coordinates?
    var timezone: Timezone?
}

struct Street: Codable {
    var number: Int?
    var name: String?
}

struct Coordinates: Codable {
    var latitude: String?
    var longitude: String?
}

struct Timezone: Codable {
    var offset: String?
    var description: String?
}

struct LoginDetails: Codable {
    var uuid: String?
    var username: String?
    var password: String?
    var salt: String?
    var md5: String?
    var sha1: String?
    var sha256: String?
}
