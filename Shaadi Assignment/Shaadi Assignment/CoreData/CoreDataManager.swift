//
// CoreDataManager.swift
// Cityflo
//
// Created by Anshul Gupta on 06/08/24.
// Copyright © Cityflo. All rights reserved.
//


import CoreData

enum CoreDataError: Error {
    case fetchError(Error)
    case saveError(Error)
    case updateError(Error)
    case noProfileFound
}

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Shaadi_Assignment")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func fetchData() throws -> [Profile] {
        let fetchRequest: NSFetchRequest<Profile> = Profile.fetchRequest()
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            throw CoreDataError.fetchError(error)
        }
    }
    
    func fetchProfile(byId id: UUID) throws -> Profile? {
        let fetchRequest: NSFetchRequest<Profile> = Profile.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id.uuidString)
        
        do {
            let profiles = try viewContext.fetch(fetchRequest)
            return profiles.first
        } catch {
            throw CoreDataError.fetchError(error)
        }
    }
    
    func saveData() throws {
        do {
            try viewContext.save()
        } catch {
            throw CoreDataError.saveError(error)
        }
    }
    
    func updateProfile(byId id: UUID, withUpdates updates: [String: Any]) throws -> Bool {
        guard let profile = try fetchProfile(byId: id) else {
            throw CoreDataError.noProfileFound
        }
        
        applyUpdates(to: profile, with: updates)
        
        do {
            try viewContext.save()
            return true
        } catch {
            throw CoreDataError.updateError(error)
        }
    }
    
    private func applyUpdates(to profile: Profile, with updates: [String: Any]) {
        if let name = updates["name"] as? String {
            profile.name = name
        }
        if let location = updates["location"] as? String {
            profile.location = location
        }
        if let picture = updates["picture"] as? Data {
            profile.picture = picture
        }
        if let isAccepted = updates["isAccepted"] as? Bool {
            profile.isAccepted = isAccepted as NSNumber
        }
        if let isSynced = updates["isSynced"] as? Bool {
            profile.isSynced = isSynced as NSNumber
        }
    }
}
