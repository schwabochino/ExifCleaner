import SwiftUI

struct MetadataComparisonView: View {
    @ObservedObject var imageProcessor: ImageProcessor
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImageIndex = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Metadaten-Vergleich")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button("Fertig") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
                .background(Color(NSColor.controlBackgroundColor))
                
                Divider()
                
                if imageProcessor.originalImages.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "photo.stack")
                            .font(.system(size: 48, weight: .ultraLight))
                            .foregroundColor(.secondary)
                        
                        Text("Keine Bilder verarbeitet")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("Verarbeiten Sie zuerst einige Bilder, um die Metadaten zu vergleichen.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 0) {
                        // Image selector
                        if imageProcessor.originalImages.count > 1 {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Array(imageProcessor.originalImages.enumerated()), id: \.offset) { index, image in
                                        Button(action: {
                                            selectedImageIndex = index
                                        }) {
                                            VStack(spacing: 8) {
                                                Image(nsImage: image)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 60, height: 60)
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                
                                                Text("Bild \(index + 1)")
                                                    .font(.caption2)
                                                    .foregroundColor(selectedImageIndex == index ? .accentColor : .secondary)
                                            }
                                            .padding(8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(selectedImageIndex == index ? Color.accentColor.opacity(0.1) : Color.clear)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedImageIndex == index ? Color.accentColor : Color.clear, lineWidth: 2)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 30)
                            }
                            .padding(.vertical, 16)
                            .background(Color(NSColor.controlBackgroundColor))
                            
                            Divider()
                        }
                        
                        // Comparison view
                        HStack(spacing: 0) {
                            // Original metadata
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    Text("Vorher (Original)")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.orange.opacity(0.1))
                                
                                ScrollView {
                                    LazyVStack(alignment: .leading, spacing: 8) {
                                        if selectedImageIndex < imageProcessor.originalMetadata.count {
                                            let metadata = imageProcessor.originalMetadata[selectedImageIndex]
                                            let items = imageProcessor.getMetadataDescription(for: metadata)
                                            
                                            if items.isEmpty {
                                                Text("Keine Metadaten gefunden")
                                                    .font(.body)
                                                    .foregroundColor(.secondary)
                                                    .padding(.horizontal, 20)
                                                    .padding(.top, 20)
                                            } else {
                                                ForEach(items) { item in
                                                    MetadataRowView(item: item)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.bottom, 20)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color(NSColor.windowBackgroundColor))
                            
                            Divider()
                            
                            // Processed metadata
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Image(systemName: "checkmark.shield.fill")
                                        .foregroundColor(.green)
                                    Text("Nachher (Bereinigt)")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.green.opacity(0.1))
                                
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 20) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("✅ Alle sensiblen Metadaten entfernt")
                                                .font(.body)
                                                .fontWeight(.medium)
                                                .foregroundColor(.green)
                                            
                                            Text("Das bereinigte Bild enthält keine EXIF-Daten, GPS-Koordinaten oder andere identifizierende Informationen mehr.")
                                                .font(.body)
                                                .foregroundColor(.secondary)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Entfernte Daten:")
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                            
                                            if selectedImageIndex < imageProcessor.originalMetadata.count {
                                                let metadata = imageProcessor.originalMetadata[selectedImageIndex]
                                                let items = imageProcessor.getMetadataDescription(for: metadata)
                                                let sensitiveItems = items.filter { $0.isSensitive }
                                                
                                                if sensitiveItems.isEmpty {
                                                    Text("• Keine sensiblen Daten gefunden")
                                                        .font(.body)
                                                        .foregroundColor(.secondary)
                                                } else {
                                                    ForEach(sensitiveItems) { item in
                                                        Text("• \(item.key)")
                                                            .font(.body)
                                                            .foregroundColor(.secondary)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.top, 20)
                                    .padding(.bottom, 20)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color(NSColor.windowBackgroundColor))
                        }
                    }
                }
            }
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

struct MetadataRowView: View {
    let item: MetadataItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.key)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if item.isSensitive {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                Spacer()
            }
            
            Text(item.value)
                .font(.body)
                .foregroundColor(.secondary)
                .textSelection(.enabled)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(item.isSensitive ? Color.orange.opacity(0.05) : Color.clear)
        )
    }
}

#Preview {
    MetadataComparisonView(imageProcessor: ImageProcessor())
} 