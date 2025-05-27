import SwiftUI

struct ContentView: View {
    @StateObject private var imageProcessor = ImageProcessor()
    @State private var showingMetadataComparison = false
    @State private var dragOver = false
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.accentColor)
                    
                    Text("EXIF Cleaner")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Entfernt sensible Metadaten aus Ihren Bildern")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Label("Unterstützte Formate", systemImage: "photo.stack")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• JPEG (.jpg, .jpeg)")
                        Text("• PNG (.png)")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                if imageProcessor.processedImages.count > 0 {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Verarbeitete Bilder", systemImage: "checkmark.circle")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Text("\(imageProcessor.processedImages.count) Bild(er) bereinigt")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("🔒 Vollständig lokal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Keine Cloud-Verbindung")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(20)
            .frame(minWidth: 250, maxWidth: 300)
            .background(Color(NSColor.controlBackgroundColor))
        } detail: {
            // Main content area
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Bilder bereinigen")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    if !imageProcessor.processedImages.isEmpty {
                        Button("Metadaten vergleichen") {
                            showingMetadataComparison = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 30)
                .padding(.bottom, 20)
                
                // Drop zone or results
                if imageProcessor.originalImages.isEmpty {
                    DropZoneView(imageProcessor: imageProcessor)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 200, maximum: 300), spacing: 20)
                        ], spacing: 20) {
                            ForEach(Array(imageProcessor.originalImages.enumerated()), id: \.offset) { index, image in
                                ImageCardView(
                                    originalImage: image,
                                    processedImage: index < imageProcessor.processedImages.count ? imageProcessor.processedImages[index] : nil,
                                    isProcessing: imageProcessor.isProcessing && index == imageProcessor.originalImages.count - 1
                                )
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .sheet(isPresented: $showingMetadataComparison) {
            MetadataComparisonView(imageProcessor: imageProcessor)
        }
        .alert("Fehler", isPresented: .constant(imageProcessor.errorMessage != nil)) {
            Button("OK") {
                imageProcessor.errorMessage = nil
            }
        } message: {
            Text(imageProcessor.errorMessage ?? "")
        }
    }
}

struct ImageCardView: View {
    let originalImage: NSImage
    let processedImage: NSImage?
    let isProcessing: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Image preview
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .frame(height: 200)
                
                if let processedImage = processedImage {
                    Image(nsImage: processedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(nsImage: originalImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .opacity(isProcessing ? 0.5 : 1.0)
                }
                
                if isProcessing {
                    ProgressView()
                        .scaleEffect(1.2)
                }
            }
            
            // Status
            HStack {
                Image(systemName: processedImage != nil ? "checkmark.circle.fill" : "clock.fill")
                    .foregroundColor(processedImage != nil ? .green : .orange)
                
                Text(processedImage != nil ? "Bereinigt" : (isProcessing ? "Verarbeitung..." : "Wartend"))
                    .font(.caption)
                    .fontWeight(.medium)
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    ContentView()
} 