#!/bin/bash
# =================================================================
# WARP DESK AUTOMATION PATCHER - VERSION 2026.03
# PROPERTY OF PT CAHAYA PUNCAK LESTARI (CPL)
# =================================================================

# 1. KONFIGURASI INFRASTRUKTUR (The Source of Truth)
RELAY_SERVER="relay.cplcore.cloud:21816"
API_SERVER="https://api.cplcore.cloud"
PUB_KEY="2PzzrPq9us5BPY390b8EB5C8gzVeNnm37WuEiihUOmM="
APP_NAME="Warp Desk"
PACKAGE_ID="id.cplcore.warpdesk"

echo "🚀 Starting Patching Process for $APP_NAME..."

# 2. PATCHING FLUTTER (Metadata & Branding)
echo "📦 Patching pubspec.yaml..."
sed -i "s/name: rustdesk/name: warpdesk/g" pubspec.yaml
sed -i "s/description: .*$/description: High-speed Remote Desktop by PT CPL/g" pubspec.yaml

# 3. PATCHING RUST CONSTANTS (Hardcoded Connection)
# File ini paling sering berubah lokasinya antara versi.
# Target utama: libs/hbb_common/src/config.rs ATAU src/common.rs
TARGET_RUST_FILE=$(find . -name "common.rs" -o -name "config.rs" | grep "hbb_common" | head -n 1)

if [ -f "$TARGET_RUST_FILE" ]; then
    echo "⚙️ Patching Rust constants in $TARGET_RUST_FILE..."
    # Menggunakan regex yang lebih kuat untuk menangkap variasi spasi
    sed -i "s/RENDEZVOUS_SERVER\s*=\s*\".*\"/RENDEZVOUS_SERVER = \"$RELAY_SERVER\"/g" "$TARGET_RUST_FILE"
    sed -i "s/RS_PUB_KEY\s*=\s*\".*\"/RS_PUB_KEY = \"$PUB_KEY\"/g" "$TARGET_RUST_FILE"
    sed -i "s/API_SERVER\s*=\s*\".*\"/API_SERVER = \"$API_SERVER\"/g" "$TARGET_RUST_FILE"
else
    echo "❌ Error: Rust config file not found!"
    exit 1
fi

# 4. PATCHING ANDROID IDENTITIES
echo "📱 Patching Android Package ID..."
if [ -f "android/app/build.gradle" ]; then
    sed -i "s/applicationId \".*\"/applicationId \"$PACKAGE_ID\"/g" android/app/build.gradle
fi

# 5. SWAP ASSETS (Branding Visual)
echo "🎨 Swapping Visual Assets..."
if [ -d "./branding" ]; then
    # Mengganti logo utama di Flutter assets
    cp ./branding/logo.png ./assets/logo.png 2>/dev/null || echo "⚠️ Warning: logo.png not found in ./branding"
    # Mengganti ikon Windows
    cp ./branding/icon.ico ./windows/runner/resources/app_icon.ico 2>/dev/null
else
    echo "⚠️ Warning: ./branding folder not found. Skipping asset swap."
fi

echo "✅ $APP_NAME Patching Completed Successfully!"
