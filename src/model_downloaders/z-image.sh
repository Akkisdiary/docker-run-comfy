#!/bin/bash

set -e

echo "Downloading Z-Image models..."

download_hf "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors" "$TEXT_ENCODERS_DIR/qwen_3_4b.safetensors" &
download_hf "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors" "$DIFFUSION_MODELS_DIR/z_image_turbo_bf16.safetensors" &
download_hf "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors" "$VAES_DIR/ae.safetensors" &
download_hf "https://huggingface.co/akkisdiary/myra-ai/resolve/main/z-image/ohmyra.safetensors" "$LORAS_DIR/ohmyra.safetensors" &
