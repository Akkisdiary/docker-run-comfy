#!/bin/bash

set -e

echo "Downloading Flux fp8 models..."

download_hf "https://huggingface.co/lllyasviel/flux1_dev/resolve/main/flux1-dev-fp8.safetensors" "$DIFFUSION_MODELS_DIR/flux1-dev-fp8.safetensors"
download_hf "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn_scaled.safetensors" "$TEXT_ENCODERS_DIR/t5xxl_fp8_e4m3fn_scaled.safetensors" &
download_hf "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors" "$TEXT_ENCODERS_DIR/clip_l.safetensors" &
download_hf "https://huggingface.co/realung/flux1-dev.safetensors/resolve/main/ae.safetensors" "$VAES_DIR/ae.safetensors" &

download_hf "https://huggingface.co/alimama-creative/FLUX.1-Turbo-Alpha/resolve/main/diffusion_pytorch_model.safetensors" "$LORAS_DIR/flux1-turbo-alpha.safetensors" &
download_hf "https://huggingface.co/akkisdiary/myra-ai/resolve/main/flux/myra_flux.safetensors" "$LORAS_DIR/myra_flux.safetensors" &
# https://civitai.com/models/580857/realistic-skin-texture-style-xl-detailed-skin-sd15-flux1d-pony-illu?modelVersionId=1081450
download_civitai "1081450" "$LORAS_DIR" &
# https://civitai.com/models/1662740/lenovo-ultrareal?modelVersionId=1881976
download_civitai "1881976" "$LORAS_DIR" &