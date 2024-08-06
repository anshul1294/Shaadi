//
// ViewModel.swift
// Cityflo
//
// Created by Anshul Gupta on 04/08/24.
// Copyright © Cityflo. All rights reserved.
//


import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published public var profiles: [CardModel] = []
    @Published var state: ProfileViewState = .empty
    // MARK: This page number property should start from 0 to n but right now api response for each page is giving different numbers of profiles so kept as static
    private var pageNumber = 10
    private var cancellables = Set<AnyCancellable>()
    private var networkMonitor = NetworkMonitor.shared
    
    init() {
        networkMonitor.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.fetchData(isConnected: isConnected)
            }
            .store(in: &cancellables)
        
        let fileManager = FileManager.default
           let urls = fileManager.urls(for: .libraryDirectory, in: .userDomainMask)
           let libraryURL = urls.last!
           let sqlitePath = libraryURL.appendingPathComponent("Application Support/YourDatabase.sqlite")
           
           let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last!
           let destinationPath = documentsURL.appendingPathComponent("YourDatabase.sqlite")
           
           do {
               if fileManager.fileExists(atPath: destinationPath.path) {
                   try fileManager.removeItem(at: destinationPath)
               }
               try fileManager.copyItem(at: sqlitePath, to: destinationPath)
               print("SQLite file copied to Documents directory")
           } catch {
               print("Error copying SQLite file: \(error)")
           }
    }
    
    func fetchData(isConnected: Bool) {
        if isConnected {
            fetchFromAPI()
        } else {
            fetchFromCoreData()
        }
    }
    
    private func fetchFromAPI() {
        state = .loading
        let params: [String: Any] = ["results": pageNumber]
        NetworkManager.shared.fetchData(from: Endpoint.getProfileData, with: params)
            .decode(type: Matrimonial.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.state = .error("Failed to update profile: \(error.localizedDescription)")
                    self.fetchFromCoreData()
                case .finished:
                    break
                }
            }, receiveValue: { matrimonial in
                let cardModels = self.convertMatrimonialToCardModels(matrimonial: matrimonial)
                self.profiles = cardModels
                self.saveToDB()
                self.state = .loaded
            })
            .store(in: &cancellables)
    }
    
    private func fetchFromCoreData() {
        do {
            let localProfiles = try CoreDataManager.shared.fetchData()
            self.profiles = localProfiles.map { $0.convertProfileToCardModel() }
            self.state = .loaded
        } catch {
            self.state = .error("Failed to fetch data from Core Data: \(error.localizedDescription)")
        }
    }
    
    private func saveToDB() {
        do {
            let _ = self.profiles.map { $0.convertCardModelToProfile(context: CoreDataManager.shared.viewContext) }
            try CoreDataManager.shared.saveData()
        } catch {
            self.state = .error("Failed to save data to Core Data: \(error.localizedDescription)")
        }
    }
    
    func convertMatrimonialToCardModels(matrimonial: Matrimonial, isAccepted: Bool? = nil, isSynced: Bool? = nil) -> [CardModel] {
        return matrimonial.results?.compactMap { $0.toCardModel(isAccepted: isAccepted, isSynced: isSynced) } ?? []
    }
    
    public func accept(profile: CardModel) {
        let data: [String: Any] = ["isAccepted": true]
        do {
            let isUpdate = try CoreDataManager.shared.updateProfile(byId: profile.id, withUpdates: data)
            if isUpdate {
                if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
                    profiles[index].isAccepted = true
                }
                syncProfileToNetwork()
            } else {
                state = .error("No profile found to update")
            }
        } catch {
            state = .error("Failed to update profile: \(error.localizedDescription)")
        }
    }
    
    public func reject(profile: CardModel) {
        let data: [String: Any] = ["isAccepted": false]
        do {
            let isUpdate = try CoreDataManager.shared.updateProfile(byId: profile.id, withUpdates: data)
            if isUpdate {
                if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
                    profiles[index].isAccepted = false
                }
                syncProfileToNetwork()
            } else {
                state = .error("No profile found to update")
            }
        } catch {
            state = .error("Failed to update profile: \(error.localizedDescription)")
        }
    }
    
    // MARK: This func to increase page number after scroll to th end of page but right now api response for each page is giving different numbers of profiles so not useing it
    func incrementPage() {
        
    }
    
    // MARK: This func to sync status to network
    func syncProfileToNetwork() {
        
    }
}


enum ProfileViewState {
    case loading
    case loaded
    case error(String)
    case empty
}
