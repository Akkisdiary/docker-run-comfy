#!/bin/bash

set -e

MODELS_DIR="/ComfyUI/models"
DIFFUSION_MODELS_DIR="$MODELS_DIR/diffusion_models"
TEXT_ENCODERS_DIR="$MODELS_DIR/text_encoders"
CLIPS_DIR="$MODELS_DIR/clip"
LORAS_DIR="$MODELS_DIR/loras"
UNETS_DIR="$MODELS_DIR/unet"
VAES_DIR="$MODELS_DIR/vae"
UPSCALE_MODELS_DIR="$MODELS_DIR/upscale_models"
DETECTION_DIR="$MODELS_DIR/detection"

mkdir -p "$DIFFUSION_MODELS_DIR"
mkdir -p "$TEXT_ENCODERS_DIR"
mkdir -p "$CLIPS_DIR"
mkdir -p "$LORAS_DIR"
mkdir -p "$UNETS_DIR"
mkdir -p "$VAES_DIR"
mkdir -p "$UPSCALE_MODELS_DIR"

echo "🚀 Starting parallel model downloads..."

if [ "$DOWNLOAD_WAN22" == "true" ]; then
    echo "Downloading WAN22 models..."
    download_hf "https://huggingface.co/QuantStack/Wan2.2-T2V-A14B-GGUF/resolve/main/HighNoise/Wan2.2-T2V-A14B-HighNoise-Q8_0.gguf" "$UNETS_DIR/Wan2.2-T2V-A14B-HighNoise-Q8_0.gguf" &
    download_hf "https://huggingface.co/QuantStack/Wan2.2-T2V-A14B-GGUF/resolve/main/LowNoise/Wan2.2-T2V-A14B-LowNoise-Q8_0.gguf" "$UNETS_DIR/Wan2.2-T2V-A14B-LowNoise-Q8_0.gguf" &

    download_hf "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" "$CLIPS_DIR/umt5_xxl_fp8_e4m3fn_scaled.safetensors" &
    download_hf "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors" "$VAES_DIR/wan_2.1_vae.safetensors" &

    download_hf "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors" "$LORAS_DIR/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors" &
    download_hf "https://huggingface.co/akkisdiary/myra-ai/resolve/main/wan22/myra_wan22.safetensors" "$LORAS_DIR/myra_wan22.safetensors" &
    # https://civitai.com/models/1822984/instagirl-wan-22?modelVersionId=2180477
    download_civitai "2180477" "$LORAS_DIR" &
    # https://civitai.com/models/1662740/lenovo-ultrareal?modelVersionId=2066914
    download_civitai "2066914" "$LORAS_DIR" &
    # [Flux/Pony] Perfect Full Round Breasts & Slim Waist
    # https://civitai.com/models/61099?modelVersionId=2321128
    download_civitai "2321128" "$LORAS_DIR" &
fi

if [ "$DOWNLOAD_FLUX_FP8" == "true" ]; then
    echo "Downloading FLUX FP8 models..."
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
fi

if [ "$DOWNLOAD_FLUX_KONTEXT" == "true" ]; then
    echo "Downloading FLUX KONTEXT models..."
    download_hf "https://huggingface.co/black-forest-labs/FLUX.1-Kontext-dev/resolve/main/flux1-kontext-dev.safetensors" "$DIFFUSION_MODELS_DIR/flux1-kontext-dev.safetensors" &
    download_hf "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn_scaled.safetensors" "$TEXT_ENCODERS_DIR/t5xxl_fp8_e4m3fn_scaled.safetensors" &
    download_hf "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors" "$TEXT_ENCODERS_DIR/clip_l.safetensors" &
    download_hf "https://huggingface.co/realung/flux1-dev.safetensors/resolve/main/ae.safetensors" "$VAES_DIR/ae.safetensors" &
fi

if [ "$DOWNLOAD_CHROMA" == "true" ]; then
    echo "Downloading CHROMA models..."
    download_hf "https://huggingface.co/lodestones/Chroma/resolve/main/chroma-unlocked-v50.safetensors" "$DIFFUSION_MODELS_DIR/chroma-unlocked-v50.safetensors" &
    download_hf "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors" "$TEXT_ENCODERS_DIR/t5xxl_fp16.safetensors" &
    download_hf "https://huggingface.co/lodestones/Chroma/resolve/main/ae.safetensors" "$VAES_DIR/ae.safetensors" &
fi

if [ "$DOWNLOAD_ZIMAGE" == "true" ]; then
    download_hf "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors" "$TEXT_ENCODERS_DIR/qwen_3_4b.safetensors" &
    download_hf "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors" "$DIFFUSION_MODELS_DIR/z_image_turbo_bf16.safetensors" &
    download_hf "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors" "$VAES_DIR/ae.safetensors" &
    download_hf "https://huggingface.co/akkisdiary/myra-ai/resolve/main/z-image/ohmyra.safetensors" "$LORAS_DIR/ohmyra.safetensors" &
    download_hf "https://huggingface.co/akkisdiary/myra-ai/resolve/main/z-image/ohmyra_000003000.safetensors" "$LORAS_DIR/ohmyra_000003000.safetensors" &
fi

# Steady Dancer
if [ "$DOWNLOAD_STEADY_DANCER" == "true" ]; then
    echo "Downloading Steady Dancer..."
    download_hf "https://huggingface.co/Kijai/WanVideo_comfy_fp8_scaled/resolve/main/SteadyDancer/Wan21_SteadyDancer_fp8_e4m3fn_scaled_KJ.safetensors" "$DIFFUSION_MODELS_DIR/Wan21_SteadyDancer_fp8_e4m3fn_scaled_KJ.safetensors" &
    download_hf "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors" "$LORAS_DIR/lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors" &
    download_hf "https://huggingface.co/JunkyByte/easy_ViTPose/resolve/main/onnx/wholebody/vitpose-l-wholebody.onnx" "$DETECTION_DIR/vitpose-l-wholebody.onnx" &
    download_hf "https://huggingface.co/Wan-AI/Wan2.2-Animate-14B/blob/main/process_checkpoint/det/yolov10m.onnx" "$DETECTION_DIR/yolov10m.onnx" &
fi

# Up-Scalers
if [ "$DOWNLOAD_UPSCALER" == "true" ]; then
    echo "Downloading Up-Scalers..."
    download_hf "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x_NMKD-Siax_200k.pth" "$UPSCALE_MODELS_DIR/4x_NMKD-Siax_200k.pth" &
    # download_hf "https://huggingface.co/wavespeed/misc/resolve/main/upscalers/4xLSDIR.pth" "$UPSCALE_MODELS_DIR/4xLSDIR.pth" &
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
