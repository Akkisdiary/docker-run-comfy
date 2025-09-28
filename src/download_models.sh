#!/bin/bash

# Default Models Download Script
# Downloads essential models for ComfyUI in parallel

set +e  # Don't exit on errors

echo "📥 Starting default models download..."

# Use environment variables
NETWORK_VOLUME="${NETWORK_VOLUME:-/workspace}"
MODELS_DIR="$NETWORK_VOLUME/ComfyUI/models"

# Create models directory structure
mkdir -p "$MODELS_DIR/clip"
mkdir -p "$MODELS_DIR/loras"
mkdir -p "$MODELS_DIR/unet"

CLIPS_DIR="$MODELS_DIR/clip"
LORAS_DIR="$MODELS_DIR/loras"
UNETS_DIR="$MODELS_DIR/unet"

# Function to download models in parallel
download_models() {
    echo "🚀 Starting parallel model downloads..."
    
    # Array to store background process IDs
    local pids=()
    
    # UNet models
    echo "📦 Starting UNet model downloads..."
    (
        echo "🔧 Downloading Wan2.2 HighNoise UNet..."
        download_hf "https://huggingface.co/QuantStack/Wan2.2-T2V-A14B-GGUF/resolve/main/HighNoise/Wan2.2-T2V-A14B-HighNoise-Q8_0.gguf" "$UNETS_DIR"
    ) &
    pids+=($!)
    
    (
        echo "🔧 Downloading Wan2.2 LowNoise UNet..."
        download_hf "https://huggingface.co/QuantStack/Wan2.2-T2V-A14B-GGUF/resolve/main/LowNoise/Wan2.2-T2V-A14B-LowNoise-Q8_0.gguf" "$UNETS_DIR"
    ) &
    pids+=($!)
    
    # LoRA models
    echo "📦 Starting LoRA model downloads..."
    (
        echo "🔧 Downloading Wan21 T2V LoRA..."
        download_hf "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors" "$LORAS_DIR"
    ) &
    pids+=($!)
    
    (
        echo "🔧 Downloading CivitAI LoRA 1..."
        download_civitai "2066914" "$LORAS_DIR"
    ) &
    pids+=($!)
    
    (
        echo "🔧 Downloading CivitAI LoRA 2..."
        download_civitai "2086717" "$LORAS_DIR"
    ) &
    pids+=($!)
    
    # CLIP model
    echo "📦 Starting CLIP model download..."
    (
        echo "🔧 Downloading UMT5 CLIP model..."
        download_hf "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" "$CLIPS_DIR"
    ) &
    pids+=($!)
    
    # Store PIDs for monitoring
    export MODEL_DOWNLOAD_PIDS="${pids[*]}"
    echo "📊 Started ${#pids[@]} parallel downloads (PIDs: ${pids[*]})"
}

# Function to wait for all downloads to complete
wait_for_downloads() {
    if [ -n "$MODEL_DOWNLOAD_PIDS" ]; then
        echo "⏳ Waiting for model downloads to complete..."
        local pids=($MODEL_DOWNLOAD_PIDS)
        local completed=0
        local failed=0
        
        for pid in "${pids[@]}"; do
            if wait $pid 2>/dev/null; then
                ((completed++))
                echo "✅ Download process $pid completed successfully"
            else
                ((failed++))
                echo "❌ Download process $pid failed"
            fi
        done
        
        echo "📊 Download Summary:"
        echo "   ✅ Completed: $completed"
        echo "   ❌ Failed: $failed"
        echo "   📁 Total processes: ${#pids[@]}"
        
        if [ $failed -eq 0 ]; then
            echo "🎉 All model downloads completed successfully!"
        else
            echo "⚠️  Some downloads failed, but continuing..."
        fi
    else
        echo "ℹ️  No downloads were started"
    fi
}

# Function to check download progress (non-blocking)
check_download_progress() {
    if [ -n "$MODEL_DOWNLOAD_PIDS" ]; then
        local pids=($MODEL_DOWNLOAD_PIDS)
        local running=0
        local completed=0
        
        for pid in "${pids[@]}"; do
            if kill -0 $pid 2>/dev/null; then
                ((running++))
            else
                ((completed++))
            fi
        done
        
        echo "📊 Download Progress: $completed/${#pids[@]} completed, $running running"
    fi
}

# Export functions for use in other scripts
export -f download_models
export -f wait_for_downloads
export -f check_download_progress

# Start downloads if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    download_models
fi
