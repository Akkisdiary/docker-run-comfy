#!/bin/bash

set -e

echo "Downloading Z-Image GGUF models..."

download_hf "https://huggingface.co/gguf-org/z-image-gguf/resolve/main/z-image-turbo-q6_k.gguf" "$DIFFUSION_MODELS_DIR/z-image-turbo-q6_k.gguf" &
download_hf "https://huggingface.co/gguf-org/z-image-gguf/resolve/main/pig_flux_vae_fp32-f16.gguf" "$VAES_DIR/pig_flux_vae_fp32-f16.gguf" &
download_hf "https://huggingface.co/gguf-org/z-image-gguf/resolve/main/qwen3_4b_f32-q4_0.gguf" "$TEXT_ENCODERS_DIR/qwen3_4b_f32-q4_0.gguf" &
download_hf "https://huggingface.co/akkisdiary/myra-ai/resolve/main/z-image/ohmyra.safetensors" "$LORAS_DIR/ohmyra.safetensors" &
