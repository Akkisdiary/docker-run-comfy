#!/bin/bash

set -e

echo "🚀 Starting parallel model downloads..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MD_DIR="$SCRIPT_DIR/model_downloaders"

mkdir -p "$DIFFUSION_MODELS_DIR"
mkdir -p "$TEXT_ENCODERS_DIR"
mkdir -p "$CLIPS_DIR"
mkdir -p "$CLIP_VISION_DIR"
mkdir -p "$LORAS_DIR"
mkdir -p "$UNETS_DIR"
mkdir -p "$VAES_DIR"
mkdir -p "$UPSCALE_MODELS_DIR"
mkdir -p "$DETECTION_DIR"

if [ "$DOWNLOAD_WAN22" == "true" ]; then
    source "$MD_DIR/wan-22.sh"
fi

if [ "$DOWNLOAD_WAN22_ANIMATE" == "true" ]; then
    source "$MD_DIR/wan-animate.sh"
fi

if [ "$DOWNLOAD_FLUX_FP8" == "true" ]; then
    source "$MD_DIR/flux-fp8.sh"
fi

if [ "$DOWNLOAD_FLUX_KONTEXT" == "true" ]; then
    source "$MD_DIR/flux-konext.sh"
fi

if [ "$DOWNLOAD_CHROMA" == "true" ]; then
    source "$MD_DIR/chroma.sh"
fi

if [ "$DOWNLOAD_ZIMAGE" == "true" ]; then
    source "$MD_DIR/z-image.sh"
fi

if [ "$DOWNLOAD_ZIMAGE_GGUF" == "true" ]; then
    source "$MD_DIR/z-image-gguf.sh"
fi

if [ "$DOWNLOAD_STEADY_DANCER" == "true" ]; then
    source "$MD_DIR/steady-dancer.sh"
fi

if [ "$DOWNLOAD_UPSCALER" == "true" ]; then
    source "$MD_DIR/upscalers.sh"
fi

echo "⏳ Waiting for model downloads to complete..."
sleep 5

while pgrep -x "curl" > /dev/null; do
    echo "🔽 Model downloads still in progress [$(pgrep -x "curl" | tr '\n' ',' | sed 's/,$//')]..."
    sleep 5  # Check every 5 seconds
done
while pgrep -x "aria2c" > /dev/null; do
    echo "🔽 Model downloads still in progress [$(pgrep -x "aria2c" | tr '\n' ',' | sed 's/,$//')]..."
    sleep 5  # Check every 5 seconds
done

echo "✅ Downloading models complete"
tree "$MODELS_DIR"
