# EXIF Cleaner

Eine minimalistische, elegante macOS-App zum sicheren Entfernen von EXIF-Daten und anderen sensiblen Metadaten aus Bildern.

## Features

- 🔒 **Vollständig lokal** - Keine Cloud-Verbindung, alle Daten bleiben auf Ihrem Mac
- 🖼️ **Drag & Drop** - Einfaches Ziehen von Bildern in die App
- 📁 **Dateiauswahl** - Alternative Auswahl über den Datei-Browser
- 🔍 **Metadaten-Vergleich** - Vorher/Nachher-Ansicht der entfernten Daten
- 🎨 **Modernes Design** - Inspiriert von Bear, Craft und Pixelmator
- 🌙 **Dark Mode** - Vollständige Unterstützung für helle und dunkle Themes
- ⚡ **Schnell** - Effiziente Verarbeitung auch großer Bilddateien

## Unterstützte Formate

- JPEG (.jpg, .jpeg)
- PNG (.png)

## Entfernte Metadaten

Die App entfernt automatisch alle sensiblen Metadaten, einschließlich:

- **EXIF-Daten**: Kameramodell, Einstellungen, Software
- **GPS-Koordinaten**: Standortinformationen
- **Zeitstempel**: Aufnahmedatum und -zeit
- **Geräteinformationen**: Hersteller, Modell, Seriennummer
- **Benutzerinformationen**: Copyright, Künstler, Kommentare

## Installation

### Voraussetzungen

- macOS 13.0 oder neuer
- Xcode 15.0 oder neuer (für Entwicklung)

### Entwicklung

1. Repository klonen:
```bash
git clone <repository-url>
cd ExifCleaner
```

2. Projekt in Xcode öffnen:
```bash
open ExifCleaner.xcodeproj
```

3. Bundle Identifier anpassen:
   - Öffnen Sie die Projekteinstellungen
   - Ändern Sie `com.yourcompany.ExifCleaner` zu Ihrer eigenen Bundle ID

## Code-Signierung und Notarisierung

Für die Verteilung über den Mac App Store oder als notarisierte App außerhalb des Stores:

### 1. Apple Developer Account

- Registrieren Sie sich bei [Apple Developer Program](https://developer.apple.com/programs/)
- Erstellen Sie ein App-spezifisches Zertifikat

### 2. Code-Signierung einrichten

1. **Xcode-Einstellungen**:
   - Gehen Sie zu Xcode → Preferences → Accounts
   - Fügen Sie Ihr Apple Developer Account hinzu

2. **Projekt-Einstellungen**:
   - Wählen Sie das ExifCleaner Target
   - Unter "Signing & Capabilities":
     - Aktivieren Sie "Automatically manage signing"
     - Wählen Sie Ihr Team aus
     - Stellen Sie sicher, dass "Hardened Runtime" aktiviert ist

3. **Bundle Identifier**:
   - Ändern Sie `com.yourcompany.ExifCleaner` zu einer eindeutigen ID
   - Format: `com.ihrefirma.ExifCleaner`

### 3. App Store Distribution

1. **Archive erstellen**:
   ```bash
   # In Xcode: Product → Archive
   ```

2. **App Store Connect**:
   - Laden Sie das Archive über Xcode Organizer hoch
   - Konfigurieren Sie App-Metadaten in App Store Connect

### 4. Notarisierung für direkte Distribution

1. **Archive für Distribution**:
   ```bash
   xcodebuild -project ExifCleaner.xcodeproj \
              -scheme ExifCleaner \
              -configuration Release \
              -archivePath ExifCleaner.xcarchive \
              archive
   ```

2. **App exportieren**:
   ```bash
   xcodebuild -exportArchive \
              -archivePath ExifCleaner.xcarchive \
              -exportPath ExifCleaner-Export \
              -exportOptionsPlist ExportOptions.plist
   ```

3. **Notarisierung**:
   ```bash
   # App-spezifisches Passwort erstellen (appleid.apple.com)
   xcrun notarytool submit ExifCleaner.app.zip \
                    --apple-id "ihre-email@example.com" \
                    --password "app-spezifisches-passwort" \
                    --team-id "TEAM_ID"
   ```

4. **Notarisierung anheften**:
   ```bash
   xcrun stapler staple ExifCleaner.app
   ```

### 5. ExportOptions.plist

Erstellen Sie eine `ExportOptions.plist` für den Export:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>teamID</key>
    <string>IHRE_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
```

## Sicherheit und Datenschutz

- **Sandbox**: Die App läuft in einer sicheren Sandbox-Umgebung
- **Berechtigungen**: Nur Zugriff auf vom Benutzer ausgewählte Dateien
- **Keine Netzwerkverbindung**: Vollständig offline
- **Lokale Verarbeitung**: Alle Daten bleiben auf dem Gerät

## Architektur

```
ExifCleaner/
├── ExifCleanerApp.swift      # App-Einstiegspunkt
├── ContentView.swift         # Haupt-UI
├── DropZoneView.swift        # Drag & Drop Interface
├── MetadataView.swift        # Metadaten-Vergleich
├── ImageProcessor.swift     # Core-Logik für EXIF-Entfernung
├── Assets.xcassets/         # App-Icons und Farben
├── Info.plist              # App-Konfiguration
└── ExifCleaner.entitlements # Sicherheitsberechtigungen
```

## Verwendete Technologien

- **SwiftUI**: Moderne, deklarative UI
- **ImageIO**: Effiziente Bildverarbeitung
- **CoreGraphics**: Low-level Bildmanipulation
- **AppKit**: macOS-spezifische Funktionen

## Lizenz

[Ihre Lizenz hier einfügen]

## Support

Für Fragen oder Probleme:
- GitHub Issues: [Link zu Issues]
- E-Mail: [Ihre Support-E-Mail]

## Roadmap

- [ ] Unterstützung für weitere Bildformate (TIFF, HEIC)
- [ ] Batch-Verarbeitung von Ordnern
- [ ] Anpassbare Ausgabequalität
- [ ] Automatische Backup-Funktion
- [ ] Kommandozeilen-Interface 