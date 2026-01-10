#!/bin/bash

set -e

echo "Downloading Wan22 models..."

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