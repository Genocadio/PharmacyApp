#!/bin/bash

# Function to create rounded corner app icon
create_app_icon() {
  local size=$1
  local output=$2
  local radius=$(( size / 5 ))  # 20% corner radius (iOS/macOS style)
  
  # Render SVG at 2x size, trim, zoom to fill 85% of icon space, add rounded corners
  magick logo.svg \
    -background none \
    -trim +repage \
    -resize $(( size * 170 / 100 ))x$(( size * 170 / 100 )) \
    -gravity center \
    -extent ${size}x${size} \
    -fuzz 10% -transparent black \
    \( +clone -alpha extract \
       -draw "fill black rectangle 0,0 ${size},${size} fill white roundrectangle 0,0 ${size},${size} ${radius},${radius}" \
    \) -alpha off -compose CopyOpacity -composite \
    "$output"
}

echo "Generating app icons with rounded corners and zoomed content..."

# Android icons
echo "Generating Android icons..."
create_app_icon 48 android/app/src/main/res/mipmap-mdpi/ic_launcher.png
create_app_icon 72 android/app/src/main/res/mipmap-hdpi/ic_launcher.png
create_app_icon 96 android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
create_app_icon 144 android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
create_app_icon 192 android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
echo "✓ Android icons complete"

# iOS icons
echo "Generating iOS icons..."
create_app_icon 20 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png
create_app_icon 40 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png
create_app_icon 60 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png
create_app_icon 29 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png
create_app_icon 58 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png
create_app_icon 87 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png
create_app_icon 40 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png
create_app_icon 80 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png
create_app_icon 120 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png
create_app_icon 120 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png
create_app_icon 180 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png
create_app_icon 76 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png
create_app_icon 152 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png
create_app_icon 167 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png
create_app_icon 1024 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
echo "✓ iOS icons complete"

# macOS icons
echo "Generating macOS icons..."
create_app_icon 16 macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png
create_app_icon 32 macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png
create_app_icon 64 macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png
create_app_icon 128 macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png
create_app_icon 256 macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png
create_app_icon 512 macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png
create_app_icon 1024 macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png
echo "✓ macOS icons complete"

# Web icons
echo "Generating Web icons..."
create_app_icon 192 web/icons/Icon-192.png
create_app_icon 512 web/icons/Icon-512.png
create_app_icon 192 web/icons/Icon-maskable-192.png
create_app_icon 512 web/icons/Icon-maskable-512.png
echo "✓ Web icons complete"

# Windows icon (ICO with multiple sizes)
echo "Generating Windows icon..."
magick logo.svg \
  -background none \
  -trim +repage \
  -resize 170% \
  -gravity center \
  -extent 256x256 \
  -fuzz 10% -transparent black \
  \( +clone -alpha extract \
     -draw "fill black rectangle 0,0 256,256 fill white roundrectangle 0,0 256,256 51,51" \
  \) -alpha off -compose CopyOpacity -composite \
  -define icon:auto-resize=256,128,96,64,48,32,16 \
  windows/runner/resources/app_icon.ico
echo "✓ Windows icon complete"

echo ""
echo "=========================================="
echo "✓ All app icons generated successfully!"
echo "=========================================="
echo ""
echo "Icons features:"
echo "  • Rounded corners (20% radius)"
echo "  • Zoomed content (170% scale)"
echo "  • Transparent background"
echo ""
