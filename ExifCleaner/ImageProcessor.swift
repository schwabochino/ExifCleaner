import Foundation
import AppKit
import ImageIO
import CoreGraphics

class ImageProcessor: ObservableObject {
    @Published var originalImages: [NSImage] = []
    @Published var processedImages: [NSImage] = []
    @Published var originalMetadata: [[String: Any]] = []
    @Published var processedMetadata: [[String: Any]] = []
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    private let supportedTypes = ["jpg", "jpeg", "png"]
    
    func processImages(from urls: [URL]) {
        Task { @MainActor in
            isProcessing = true
            errorMessage = nil
            
            // Clear previous results
            originalImages.removeAll()
            processedImages.removeAll()
            originalMetadata.removeAll()
            processedMetadata.removeAll()
            
            for url in urls {
                await processImage(from: url)
            }
            
            isProcessing = false
        }
    }
    
    @MainActor
    private func processImage(from url: URL) async {
        guard supportedTypes.contains(url.pathExtension.lowercased()) else {
            errorMessage = "Nicht unterstütztes Dateiformat: \(url.pathExtension)"
            return
        }
        
        do {
            // Load original image and metadata
            guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
                  let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
                errorMessage = "Fehler beim Laden des Bildes: \(url.lastPathComponent)"
                return
            }
            
            let originalImage = NSImage(cgImage: cgImage, size: .zero)
            originalImages.append(originalImage)
            
            // Extract original metadata
            let originalMeta = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] ?? [:]
            originalMetadata.append(originalMeta)
            
            // Create cleaned image without EXIF data
            let cleanedImage = await createCleanedImage(from: cgImage, originalFormat: url.pathExtension.lowercased())
            processedImages.append(cleanedImage)
            
            // Create empty metadata for processed image
            processedMetadata.append([:])
            
            // Save cleaned image
            await saveCleanedImage(cleanedImage, originalURL: url)
            
        } catch {
            errorMessage = "Fehler bei der Verarbeitung: \(error.localizedDescription)"
        }
    }
    
    private func createCleanedImage(from cgImage: CGImage, originalFormat: String) async -> NSImage {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                // Create a new image representation without metadata
                let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
                
                // Set compression quality for JPEG
                var imageData: Data?
                
                if originalFormat == "png" {
                    imageData = bitmapRep.representation(using: .png, properties: [:])
                } else {
                    // For JPEG, use high quality compression
                    imageData = bitmapRep.representation(using: .jpeg, properties: [
                        .compressionFactor: 0.9
                    ])
                }
                
                guard let data = imageData,
                      let cleanedImage = NSImage(data: data) else {
                    continuation.resume(returning: NSImage(cgImage: cgImage, size: .zero))
                    return
                }
                
                continuation.resume(returning: cleanedImage)
            }
        }
    }
    
    private func saveCleanedImage(_ image: NSImage, originalURL: URL) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                let fileName = originalURL.deletingPathExtension().lastPathComponent
                let fileExtension = originalURL.pathExtension
                let cleanedFileName = "\(fileName)_cleaned.\(fileExtension)"
                
                // Save to Downloads folder
                let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
                let saveURL = downloadsURL.appendingPathComponent(cleanedFileName)
                
                // Get image representation
                guard let tiffData = image.tiffRepresentation,
                      let bitmapRep = NSBitmapImageRep(data: tiffData) else {
                    continuation.resume(returning: ())
                    return
                }
                
                var imageData: Data?
                
                if fileExtension.lowercased() == "png" {
                    imageData = bitmapRep.representation(using: .png, properties: [:])
                } else {
                    imageData = bitmapRep.representation(using: .jpeg, properties: [
                        .compressionFactor: 0.9
                    ])
                }
                
                if let data = imageData {
                    try? data.write(to: saveURL)
                }
                
                continuation.resume(returning: ())
            }
        }
    }
    
    func getMetadataDescription(for metadata: [String: Any]) -> [MetadataItem] {
        var items: [MetadataItem] = []
        
        // Basic image properties
        if let width = metadata[kCGImagePropertyPixelWidth as String] as? Int,
           let height = metadata[kCGImagePropertyPixelHeight as String] as? Int {
            items.append(MetadataItem(key: "Bildgröße", value: "\(width) × \(height) Pixel"))
        }
        
        if let colorModel = metadata[kCGImagePropertyColorModel as String] as? String {
            items.append(MetadataItem(key: "Farbmodell", value: colorModel))
        }
        
        if let dpi = metadata[kCGImagePropertyDPIWidth as String] as? Double {
            items.append(MetadataItem(key: "DPI", value: String(format: "%.0f", dpi)))
        }
        
        // EXIF data
        if let exif = metadata[kCGImagePropertyExifDictionary as String] as? [String: Any] {
            if let camera = exif[kCGImagePropertyExifLensMake as String] as? String {
                items.append(MetadataItem(key: "Kamera", value: camera, isSensitive: true))
            }
            
            if let model = exif[kCGImagePropertyExifLensModel as String] as? String {
                items.append(MetadataItem(key: "Kameramodell", value: model, isSensitive: true))
            }
            
            if let dateTime = exif[kCGImagePropertyExifDateTimeOriginal as String] as? String {
                items.append(MetadataItem(key: "Aufnahmedatum", value: dateTime, isSensitive: true))
            }
            
            if let software = exif[kCGImagePropertyExifSoftware as String] as? String {
                items.append(MetadataItem(key: "Software", value: software, isSensitive: true))
            }
        }
        
        // GPS data
        if let gps = metadata[kCGImagePropertyGPSDictionary as String] as? [String: Any] {
            if let latitude = gps[kCGImagePropertyGPSLatitude as String] as? Double,
               let longitude = gps[kCGImagePropertyGPSLongitude as String] as? Double {
                items.append(MetadataItem(key: "GPS-Koordinaten", value: String(format: "%.6f, %.6f", latitude, longitude), isSensitive: true))
            }
        }
        
        // TIFF data
        if let tiff = metadata[kCGImagePropertyTIFFDictionary as String] as? [String: Any] {
            if let make = tiff[kCGImagePropertyTIFFMake as String] as? String {
                items.append(MetadataItem(key: "Hersteller", value: make, isSensitive: true))
            }
            
            if let model = tiff[kCGImagePropertyTIFFModel as String] as? String {
                items.append(MetadataItem(key: "Modell", value: model, isSensitive: true))
            }
        }
        
        return items
    }
}

struct MetadataItem: Identifiable {
    let id = UUID()
    let key: String
    let value: String
    let isSensitive: Bool
    
    init(key: String, value: String, isSensitive: Bool = false) {
        self.key = key
        self.value = value
        self.isSensitive = isSensitive
    }
} 