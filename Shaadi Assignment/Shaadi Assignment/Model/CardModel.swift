//
// CardModel.swift
// Cityflo
//
// Created by Anshul Gupta on 06/08/24.
// Copyright © Cityflo. All rights reserved.
//


import Foundation
import CoreData

struct CardModel {
    let name: String
    let address: String
    let url: String
    let id: UUID
    var isAccepted: Bool?
    var isSynced: Bool?
    
    init(name: String, address: String, url: String, id: UUID, isAccepted: Bool? = nil, isSynced: Bool? = nil) {
        self.name = name
        self.address = address
        self.url = url
        self.id = id
        self.isAccepted = isAccepted
        self.isSynced = isSynced
    }
}


extension Users {
    func toCardModel(isAccepted: Bool? = nil, isSynced: Bool? = nil) -> CardModel {
        let name = "\(self.name?.first ?? "") \(self.name?.last ?? "")"
        let address = "\(self.location?.street?.number ?? 0) \(self.location?.street?.name ?? ""), \(self.location?.city ?? ""), \(self.location?.state ?? ""), \(self.location?.country ?? "")"
        let url = self.picture?.large ?? ""
        let id = UUID(uuidString: "\(String(describing: self.id?.value))") ?? UUID()
        
        return CardModel(name: name, address: address, url: url, id: id, isAccepted: isAccepted, isSynced: isSynced)
    }
}

extension CardModel {
    func convertCardModelToProfile(context: NSManagedObjectContext) -> Profile? {
        let profile = Profile(context: context)
        profile.name = self.name
        profile.location = self.address
        profile.picture = self.url.data(using: .utf8)
        profile.id = self.id
        profile.isAccepted = self.isAccepted as NSNumber?
        profile.isSynced = self.isSynced as NSNumber?
        
        do {
            try context.save()
            return profile
        } catch {
            print("Failed to save Profile: \(error)")
            return nil
        }
    }
}


