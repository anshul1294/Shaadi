//
// Profile+CoreDataProperties.swift
// Cityflo
//
// Created by Anshul Gupta on 06/08/24.
// Copyright © Cityflo. All rights reserved.
//

//

import Foundation
import CoreData


extension Profile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Profile> {
        return NSFetchRequest<Profile>(entityName: "Profile")
    }

    @NSManaged public var location: String?
    @NSManaged public var name: String?
    @NSManaged public var picture: Data?
    @NSManaged public var isAccepted: NSNumber?
    @NSManaged public var isSynced: NSNumber?
    @NSManaged public var id: UUID?

}

extension Profile : Identifiable {

}

extension Profile {
    func convertProfileToCardModel() -> CardModel {
        let name = self.name ?? ""
        let address = self.location ?? ""
        let url = String(data: self.picture ?? Data(), encoding: .utf8) ?? ""
        let id = self.id ?? UUID()
        let isAccepted = self.isAccepted?.boolValue
        let isSynced = self.isSynced?.boolValue
        
        return CardModel(name: name, address: address, url: url, id: id, isAccepted: isAccepted, isSynced: isSynced)
    }
}
