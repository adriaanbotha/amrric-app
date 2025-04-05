#!/bin/bash

# Source image
SOURCE="assets/images/AppIcon.Ios/icon.iconset/icon_1024x1024.png"
OUTPUT_DIR="ios/Runner/Assets.xcassets/AppIcon.appiconset"

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# iOS App Icon sizes
sizes=(
    "20x20@1x:20"
    "20x20@2x:40"
    "20x20@3x:60"
    "29x29@1x:29"
    "29x29@2x:58"
    "29x29@3x:87"
    "40x40@1x:40"
    "40x40@2x:80"
    "40x40@3x:120"
    "60x60@2x:120"
    "60x60@3x:180"
    "76x76@1x:76"
    "76x76@2x:152"
    "83.5x83.5@2x:167"
    "1024x1024@1x:1024"
)

# Generate each size
for size in "${sizes[@]}"; do
    name=$(echo $size | cut -d':' -f1)
    dimension=$(echo $size | cut -d':' -f2)
    
    echo "Generating $name ($dimension x $dimension)..."
    magick convert "$SOURCE" -resize "${dimension}x${dimension}" -background transparent -gravity center -extent "${dimension}x${dimension}" "$OUTPUT_DIR/Icon-App-${name}.png"
done

echo "All icons generated in $OUTPUT_DIR" 