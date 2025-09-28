#!/bin/bash

# ComfyUI Startup Script
# Handles ComfyUI service startup with GPU/CPU detection and readiness checking

set +e  # Don't exit on errors

echo "🎨 Starting ComfyUI..."

# Use environment variables
NETWORK_VOLUME="${NETWORK_VOLUME:-/workspace}"
COMFYUI_DIR="${COMFYUI_DIR:-$NETWORK_VOLUME/ComfyUI}"

# Start ComfyUI server
echo "▶️  Starting ComfyUI server..."
COMFYUI_URL="http://127.0.0.1:8188"
POD_ID="${RUNPOD_POD_ID:-container}"
export LOG_FILE="/comfyui_${POD_ID}.log"

# Check if PyTorch was compiled with CUDA support and start ComfyUI
if python3 -c "import torch; torch.cuda.current_device()" 2>/dev/null; then
    echo "🔧 CUDA detected - using GPU mode"
    # Check if sageattention is installed and available
    if python3 -c "import sageattention" 2>/dev/null; then
        echo "🔧 SageAttention detected - using optimized mode"
        python3 "$COMFYUI_DIR/main.py" --listen --use-sage-attention > "$LOG_FILE" 2>&1 &
    else
        echo "📊 Using standard CUDA mode"
        python3 "$COMFYUI_DIR/main.py" --listen > "$LOG_FILE" 2>&1 &
    fi
else
    echo "💻 No CUDA detected - using CPU mode"
    python3 "$COMFYUI_DIR/main.py" --listen --cpu > "$LOG_FILE" 2>&1 &
fi

export COMFYUI_PID=$!
echo "✅ ComfyUI started (PID: $COMFYUI_PID)"

# Wait for ComfyUI to be ready
echo "⏳ Waiting for ComfyUI to start..."
counter=0
max_wait=90

until curl --silent --fail "$COMFYUI_URL" --output /dev/null; do
    # Check if ComfyUI process is still running
    if ! kill -0 "$COMFYUI_PID" 2>/dev/null; then
        echo "❌ ComfyUI process died during startup"
        echo "📋 Last 30 lines of log:"
        tail -n 30 "$LOG_FILE" 2>/dev/null || echo "No log file found"
        exit 1
    fi
    
    if [ $counter -ge $max_wait ]; then
        echo "❌ ComfyUI failed to start within ${max_wait} seconds"
        echo "📋 Last 30 lines of log:"
        tail -n 30 "$LOG_FILE" 2>/dev/null || echo "No log file found"
        exit 1
    fi
    
    sleep 2
    counter=$((counter + 2))
done

# Check final status
if curl --silent --fail "$COMFYUI_URL" --output /dev/null; then
    echo "🚀 ComfyUI is UP and ready!"
    echo "🌐 ComfyUI URL: http://localhost:8188"
    echo "📋 Logs: $LOG_FILE"
else
    echo "❌ ComfyUI failed to start properly"
    echo "📋 Check logs: $LOG_FILE"
    exit 1
fi

echo "✅ ComfyUI startup completed"
