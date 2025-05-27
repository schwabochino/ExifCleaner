#!/bin/bash

# EXIF Cleaner Build Script
# Dieses Skript erstellt und signiert die App für die Distribution

set -e

# Konfiguration
PROJECT_NAME="ExifCleaner"
SCHEME_NAME="ExifCleaner"
CONFIGURATION="Release"
ARCHIVE_PATH="build/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="build/Export"

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 EXIF Cleaner Build Script${NC}"
echo "=================================="

# Überprüfe ob Xcode installiert ist
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Xcode ist nicht installiert oder nicht im PATH${NC}"
    exit 1
fi

# Erstelle Build-Verzeichnis
echo -e "${YELLOW}📁 Erstelle Build-Verzeichnis...${NC}"
mkdir -p build

# Clean vorherige Builds
echo -e "${YELLOW}🧹 Bereinige vorherige Builds...${NC}"
rm -rf build/*

# Build Archive
echo -e "${YELLOW}🔨 Erstelle Archive...${NC}"
xcodebuild -project "${PROJECT_NAME}.xcodeproj" \
           -scheme "${SCHEME_NAME}" \
           -configuration "${CONFIGURATION}" \
           -archivePath "${ARCHIVE_PATH}" \
           -destination "generic/platform=macOS" \
           archive

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Archive erfolgreich erstellt${NC}"
else
    echo -e "${RED}❌ Fehler beim Erstellen des Archives${NC}"
    exit 1
fi

# Überprüfe ob ExportOptions.plist existiert
if [ ! -f "ExportOptions.plist" ]; then
    echo -e "${RED}❌ ExportOptions.plist nicht gefunden${NC}"
    echo "Bitte erstellen Sie die Datei mit Ihrer Team ID"
    exit 1
fi

# Export App
echo -e "${YELLOW}📦 Exportiere App...${NC}"
xcodebuild -exportArchive \
           -archivePath "${ARCHIVE_PATH}" \
           -exportPath "${EXPORT_PATH}" \
           -exportOptionsPlist "ExportOptions.plist"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ App erfolgreich exportiert${NC}"
    echo -e "${GREEN}📍 App befindet sich in: ${EXPORT_PATH}${NC}"
else
    echo -e "${RED}❌ Fehler beim Exportieren der App${NC}"
    exit 1
fi

# Erstelle ZIP für Notarisierung
echo -e "${YELLOW}🗜️ Erstelle ZIP für Notarisierung...${NC}"
cd "${EXPORT_PATH}"
zip -r "${PROJECT_NAME}.zip" "${PROJECT_NAME}.app"
cd - > /dev/null

echo -e "${GREEN}✅ Build erfolgreich abgeschlossen!${NC}"
echo ""
echo "Nächste Schritte für Notarisierung:"
echo "1. Laden Sie ${EXPORT_PATH}/${PROJECT_NAME}.zip zur Notarisierung hoch"
echo "2. Verwenden Sie: xcrun notarytool submit ..."
echo "3. Nach erfolgreicher Notarisierung: xcrun stapler staple ..."
echo ""
echo -e "${YELLOW}📖 Siehe README.md für detaillierte Anweisungen${NC}" 