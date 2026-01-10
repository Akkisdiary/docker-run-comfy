#!/bin/bash

set -e

echo "Downloading Upscaler models..."

download_hf "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x_NMKD-Siax_200k.pth" "$UPSCALE_MODELS_DIR/4x_NMKD-Siax_200k.pth" &
# download_hf "https://huggingface.co/wavespeed/misc/resolve/main/upscalers/4xLSDIR.pth" "$UPSCALE_MODELS_DIR/4xLSDIR.pth" &
