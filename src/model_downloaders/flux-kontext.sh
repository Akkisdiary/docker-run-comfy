#!/bin/bash

set -e

echo "Downloading Flux Kontext models..."

download_hf "https://huggingface.co/black-forest-labs/FLUX.1-Kontext-dev/resolve/main/flux1-kontext-dev.safetensors" "$DIFFUSION_MODELS_DIR/flux1-kontext-dev.safetensors" &
download_hf "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn_scaled.safetensors" "$TEXT_ENCODERS_DIR/t5xxl_fp8_e4m3fn_scaled.safetensors" &
download_hf "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors" "$TEXT_ENCODERS_DIR/clip_l.safetensors" &
download_hf "https://huggingface.co/realung/flux1-dev.safetensors/resolve/main/ae.safetensors" "$VAES_DIR/ae.safetensors" &
