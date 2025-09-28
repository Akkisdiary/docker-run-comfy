#!/usr/bin/env bash
set -e

echo "🚀 Starting ComfyUI RunPod Template..."

# Use libtcmalloc for better memory management (if available)
TCMALLOC="$(ldconfig -p 2>/dev/null | grep -Po "libtcmalloc.so.\d" | head -n 1 || true)"
if [ -n "$TCMALLOC" ]; then
    export LD_PRELOAD="${TCMALLOC}"
    echo "✅ Using libtcmalloc for memory optimization"
fi

# Execute additional setup script if present
if [ -f "/workspace/additional_params.sh" ]; then
    chmod +x /workspace/additional_params.sh
    echo "🔧 Executing additional_params.sh..."
    /workspace/additional_params.sh
else
    echo "ℹ️  No additional_params.sh found, continuing..."
fi

# Set up network volume and ComfyUI directory
NETWORK_VOLUME="/workspace"
COMFYUI_DIR="$NETWORK_VOLUME/ComfyUI"

# Ensure workspace directory exists
mkdir -p "$NETWORK_VOLUME"

# Handle ComfyUI installation based on network volume state
if [ ! -d "$COMFYUI_DIR" ]; then
    echo "📦 ComfyUI not found in network volume, copying from container..."
    if [ -d "/ComfyUI" ]; then
        cp -r /ComfyUI "$COMFYUI_DIR"
        echo "✅ ComfyUI copied to network volume for persistence"
    else
        echo "❌ ComfyUI not found in container at /ComfyUI"
        exit 1
    fi
else
    echo "✅ ComfyUI found in network volume, using existing installation"
fi

# Create additional directories if they don't exist
mkdir -p "$COMFYUI_DIR/models/checkpoints"
mkdir -p "$COMFYUI_DIR/models/vae"
mkdir -p "$COMFYUI_DIR/custom_nodes"
mkdir -p "$COMFYUI_DIR/input"
mkdir -p "$COMFYUI_DIR/output"

# Start JupyterLab in ComfyUI directory
echo "📓 Starting JupyterLab server..."
jupyter-lab --ip=0.0.0.0 --allow-root --no-browser \
    --ServerApp.token='' --ServerApp.password='' \
    --ServerApp.allow_origin='*' --ServerApp.allow_credentials=True \
    --notebook-dir="$COMFYUI_DIR" &

JUPYTER_PID=$!
echo "✅ JupyterLab started (PID: $JUPYTER_PID)"

# Start ComfyUI server
echo "▶️  Starting ComfyUI server..."
COMFYUI_URL="http://127.0.0.1:8188"
POD_ID="${RUNPOD_POD_ID:-container}"
LOG_FILE="$NETWORK_VOLUME/comfyui_${POD_ID}.log"

# Check if sageattention is installed and available
if python3 -c "import sageattention" 2>/dev/null; then
    echo "🔧 SageAttention detected - using optimized mode"
    nohup python3 "$COMFYUI_DIR/main.py" --listen --use-sage-attention > "$LOG_FILE" 2>&1 &
else
    echo "ℹ️  SageAttention not available - using standard mode"
    nohup python3 "$COMFYUI_DIR/main.py" --listen > "$LOG_FILE" 2>&1 &
fi

COMFYUI_PID=$!
echo "✅ ComfyUI started (PID: $COMFYUI_PID)"

# Wait for ComfyUI to be ready
echo "⏳ Waiting for ComfyUI to start..."
counter=0
max_wait=90

until curl --silent --fail "$COMFYUI_URL" --output /dev/null; do
    if [ $counter -ge $max_wait ]; then
        echo "⚠️  ComfyUI startup timeout after ${max_wait}s"
        echo "📋 Check logs: $LOG_FILE"
        echo "🔍 Last 20 lines of log:"
        tail -n 20 "$LOG_FILE" 2>/dev/null || echo "No log file found"
        break
    fi

    if [ $((counter % 10)) -eq 0 ]; then
        echo "🔄 Still waiting... (${counter}s/${max_wait}s)"
    fi
    
    sleep 2
    counter=$((counter + 2))
done

# Check final status
if curl --silent --fail "$COMFYUI_URL" --output /dev/null; then
    echo "🚀 ComfyUI is UP and ready!"
    echo "🌐 ComfyUI URL: http://localhost:8188"
    echo "📓 JupyterLab URL: http://localhost:8888"
    echo "📋 Logs: $LOG_FILE"
else
    echo "❌ ComfyUI failed to start properly"
    echo "📋 Check logs: $LOG_FILE"
fi

# Keep container running
echo "✅ Setup complete. Container will stay running..."
sleep infinity