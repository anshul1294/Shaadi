//
// CardView.swift
// Cityflo
//
// Created by Anshul Gupta on 03/08/24.
// Copyright © Cityflo. All rights reserved.
//


import SwiftUI

struct CardView: View {
    let cardModel: CardModel
    let acceptAction: () -> Void
    let rejectAction: () -> Void
    
    init(cardModel: CardModel, acceptAction: @escaping () -> Void, rejectAction: @escaping () -> Void) {
        self.cardModel = cardModel
        self.acceptAction = acceptAction
        self.rejectAction = rejectAction
    }
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: cardModel.url)) {
                Rectangle()
                    .background(.red)
            } image: { image in
                image
                    .resizable()
                    .frame(width: 100, height: 100)
            }
            .padding(.top, 8)
            
            Text(cardModel.name)
                .frame(maxWidth: .infinity)
                .foregroundColor(.blue)
                .font(.headline)
                .padding(.horizontal, 16)
                .multilineTextAlignment(.center)

            
            Text(cardModel.address)
                .frame(maxWidth: .infinity)
                .foregroundColor(.black)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .multilineTextAlignment(.center)

            if let isAccepted = cardModel.isAccepted {
                getStatusView(status: isAccepted ? "Accepted" : "Declined")
            } else {
                HStack(spacing: 24) {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.red)
                        .onTapGesture {
                            rejectAction()
                        }
                    
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.green)
                        .onTapGesture {
                            acceptAction()
                        }
                }
                .padding(.bottom, 8)
            }
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
        
    }
    
    @ViewBuilder
    func getStatusView(status: String) -> some View {
        Text(status)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .foregroundColor(.white)
            .font(.headline)
            .background(Color.teal)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    CardView(cardModel: CardModel(name: "Anshul Gupta", address: "testing", url: "https://picsum.photos/200/300", id: UUID(), isAccepted: false, isSynced: false),acceptAction: {
        
    }, rejectAction: {
        
    })
}
