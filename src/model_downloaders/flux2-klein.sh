#!/bin/bash

set -e

echo "Downloading Flux 2 Klein models..."

download_hf "https://huggingface.co/black-forest-labs/FLUX.2-klein-4b-fp8/resolve/main/flux-2-klein-4b-fp8.safetensors" "$DIFFUSION_MODELS_DIR/flux-2-klein-4b-fp8.safetensors"
download_hf "https://huggingface.co/Comfy-Org/flux2-klein-4B/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors" "$TEXT_ENCODERS_DIR/qwen_3_4b.safetensors" &
download_hf "https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors" "$VAES_DIR/flux2-vae.safetensors" &
