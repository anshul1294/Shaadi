//
// ContentView.swift
// Cityflo
//
// Created by Anshul Gupta on 03/08/24.
// Copyright © Cityflo. All rights reserved.
//


import SwiftUI
import Combine

struct MyProfileListView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
       
        VStack {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            case .loaded:
                List(viewModel.profiles, id: \.id) { profile in
                    CardView(cardModel: profile, acceptAction: { viewModel.accept(profile: profile)}, rejectAction: { viewModel.reject(profile: profile)})
                }

            case .error(let string):
                VStack {
                    Text("Error: \(string)")
                        .foregroundColor(.red)
                    Button(action: {
                        viewModel.fetchData(isConnected: true)
                    }) {
                        Text("Retry")
                    }
                }

            case .empty:
                VStack {
                                    Text("No profiles available")
                                        .foregroundColor(.gray)
                                    Button(action: {
                             
                                    }) {
                                        Text("Retry")
                                    }
                                }

            }
        }
    }
    
    
}

#Preview {
    MyProfileListView()
}



