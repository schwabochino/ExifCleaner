import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
    @ObservedObject var imageProcessor: ImageProcessor
    @State private var dragOver = false
    @State private var showingFilePicker = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                // Icon
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 64, weight: .ultraLight))
                    .foregroundColor(dragOver ? .accentColor : .secondary)
                    .scaleEffect(dragOver ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: dragOver)
                
                // Text
                VStack(spacing: 8) {
                    Text("Bilder hier ablegen")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("oder")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Button("Dateien auswählen") {
                        showingFilePicker = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                
                // Supported formats
                VStack(spacing: 4) {
                    Text("Unterstützte Formate:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("JPEG, PNG")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(dragOver ? Color.accentColor.opacity(0.1) : Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            dragOver ? Color.accentColor : Color.secondary.opacity(0.3),
                            style: StrokeStyle(lineWidth: 2, dash: [10, 5])
                        )
                )
        )
        .onDrop(of: [.fileURL], isTargeted: $dragOver) { providers in
            handleDrop(providers: providers)
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.jpeg, .png],
            allowsMultipleSelection: true
        ) { result in
            handleFileSelection(result: result)
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        let urls = providers.compactMap { provider in
            var url: URL?
            let semaphore = DispatchSemaphore(value: 0)
            
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { data, error in
                if let data = data as? Data,
                   let path = String(data: data, encoding: .utf8),
                   let fileURL = URL(string: path) {
                    url = fileURL
                }
                semaphore.signal()
            }
            
            semaphore.wait()
            return url
        }
        
        if !urls.isEmpty {
            imageProcessor.processImages(from: urls)
            return true
        }
        
        return false
    }
    
    private func handleFileSelection(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            imageProcessor.processImages(from: urls)
        case .failure(let error):
            imageProcessor.errorMessage = "Fehler beim Laden der Dateien: \(error.localizedDescription)"
        }
    }
}

#Preview {
    DropZoneView(imageProcessor: ImageProcessor())
        .frame(width: 600, height: 400)
} 