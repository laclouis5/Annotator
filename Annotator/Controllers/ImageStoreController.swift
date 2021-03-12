//
//  ImageStoreController.swift
//  Annotator
//
//  Created by Louis Lac on 04/03/2021.
//

import Foundation
import SwiftUI
import Combine

/// Object representing the images in one folder.
/// It exposes a selection that indicates the currently selected image that is presented in the detail view.
/// This object also handles image list filtering.
final class ImageStoreController: ObservableObject {
    /// The folder where images are stored.
    @Published var folder: URL?
    
    /// All the images in the folder.
    @Published private(set) var allImages: [URL]
    
    /// The filtered list of images.
    @Published private(set) var images: [URL]
    
    /// The filter predicate.
    @Published var filterText: String
    
    /// The selected image.
    @Published var selection: URL?
    
    init(folder: URL? = nil) {
        self.folder = folder
        self.allImages = []
        self.images = []
        self.filterText = ""
        
        // Publisher that updates the image list when folder is changed.
        $folder
            .removeDuplicates()
            .map { (url: URL?) -> [URL] in
                guard let url = url else { return [] }
                
                var images = (try? FileManager.default
                    .contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
                    .filter { Set(["jpg", "jpeg", "png"]).contains($0.pathExtension) }) ?? []
                
                images.sort(by: \.lastPathComponent)
                return images
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$allImages)
        
        // Publisher that updates the filtered image list when either the list or the filter text change.
        Publishers.CombineLatest(
            $allImages,
            $filterText
                .throttle(for: .milliseconds(150), scheduler: DispatchQueue.main, latest: true)
                .map { text in text.trimmingCharacters(in: .whitespacesAndNewlines) }
                .removeDuplicates()
        )
        .map { (imageList, filterText) -> [URL] in
            if filterText.isEmpty {
                return imageList
            }
            
            let filtered = imageList.filter { $0.lastPathComponent.contains(filterText) }
            return filtered
        }
        .receive(on: DispatchQueue.main)
        .assign(to: &$images)
        
        // Publisher that updates the selection when the list of images changes.
        $allImages
            .map(\.first)
            .receive(on: DispatchQueue.main)
            .assign(to: &$selection)
    }
}
