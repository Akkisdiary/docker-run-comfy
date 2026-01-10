#!/bin/bash

set -e

echo "Downloading Chroma models..."

download_hf "https://huggingface.co/lodestones/Chroma/resolve/main/chroma-unlocked-v50.safetensors" "$DIFFUSION_MODELS_DIR/chroma-unlocked-v50.safetensors" &
download_hf "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors" "$TEXT_ENCODERS_DIR/t5xxl_fp16.safetensors" &
download_hf "https://huggingface.co/lodestones/Chroma/resolve/main/ae.safetensors" "$VAES_DIR/ae.safetensors" &