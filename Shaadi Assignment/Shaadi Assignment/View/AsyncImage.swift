//
// AsyncImage.swift
// Cityflo
//
// Created by Anshul Gupta on 03/08/24.
// Copyright © Cityflo. All rights reserved.
//


import Foundation
import SwiftUI

public struct AsyncImage<Content: View, Placeholder: View>: View {
    @State private var loader: ImageLoader
    @State private var image: Image?
    private let placeholder: Placeholder
    private let content: (Image) -> Content
    
    public init(
        url: URL?,
        @ViewBuilder placeholder: () -> Placeholder,
        @ViewBuilder image: @escaping (Image) -> Content) {
            self.placeholder = placeholder()
            self.content = image
            self._loader  = State(initialValue: ImageLoader(url: url))
    }
    
    public var body: some View {
        asyncImageView
            .onAppear(perform: loader.load)
            .onReceive(loader.image) { (loadedImage) in
                if let image = loadedImage {
                    self.image = Image(uiImage: image)
                }
            }
    }
    
    @ViewBuilder
    private var asyncImageView: some View {
        if let downloadedImage = image {
            content(downloadedImage)
        } else {
            placeholder
        }
    }
}
