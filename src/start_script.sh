#!/usr/bin/env bash
set -e

echo "🚀 Setup started..."

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
if [ ! -f "$COMFYUI_DIR/main.py" ]; then
    echo "📦 ComfyUI not found in $NETWORK_VOLUME, copying from container..."
    if [ -d "/ComfyUI" ] && [ -f "/ComfyUI/main.py" ]; then
        # Copy entire ComfyUI installation to network volume
        echo "📁 Copying ComfyUI installation..."
        mv /ComfyUI "$COMFYUI_DIR"
        
        echo "✅ ComfyUI copied to $NETWORK_VOLUME"
    else
        echo "❌ ComfyUI not found in container at /ComfyUI"
        exit 1
    fi
else
    echo "✅ ComfyUI found in $NETWORK_VOLUME, using existing installation"
fi

# Create additional cache directories
mkdir -p "$NETWORK_VOLUME/cache/transformers"
mkdir -p "$NETWORK_VOLUME/cache/huggingface"

# Set up workflows symlink for development
if [ -d "/src/workflows" ]; then
    echo "🔗 Setting up workflows symlink for development..."
    
    # Create the workflows directory structure if it doesn't exist
    mkdir -p "$COMFYUI_DIR/user/default"
    
    # Remove existing workflows directory if it exists
    if [ -d "$COMFYUI_DIR/user/default/workflows" ]; then
        rm -rf "$COMFYUI_DIR/user/default/workflows"
    fi
    
    # Create symlink to workflows
    ln -sf "/src/workflows" "$COMFYUI_DIR/user/default/workflows"
    echo "✅ Workflows linked to ComfyUI"
else
    echo "📁 No workflows mount found, using built-in workflows"
fi

# Start JupyterLab in ComfyUI directory
echo "📓 Starting JupyterLab server..."
jupyter-lab --ip=0.0.0.0 --allow-root --no-browser \
    --ServerApp.token='' --ServerApp.password='' \
    --ServerApp.allow_origin='*' --ServerApp.allow_credentials=True \
    --notebook-dir="/" &

JUPYTER_PID=$!
echo "✅ JupyterLab started (PID: $JUPYTER_PID)"

# Start ComfyUI server
echo "▶️  Starting ComfyUI server..."
COMFYUI_URL="http://127.0.0.1:8188"
POD_ID="${RUNPOD_POD_ID:-container}"
LOG_FILE="/comfyui_${POD_ID}.log"

# Function to handle shutdown gracefully
cleanup() {
    echo "🛑 Shutting down services..."
    if [ -n "$COMFYUI_PID" ] && kill -0 "$COMFYUI_PID" 2>/dev/null; then
        kill -TERM "$COMFYUI_PID"
        wait "$COMFYUI_PID" 2>/dev/null || true
    fi
    if [ -n "$JUPYTER_PID" ] && kill -0 "$JUPYTER_PID" 2>/dev/null; then
        kill -TERM "$JUPYTER_PID"
        wait "$JUPYTER_PID" 2>/dev/null || true
    fi
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Check if PyTorch was compiled with CUDA support
# This specifically checks for the "Torch not compiled with CUDA enabled" error
if python3 -c "import torch; torch.cuda.current_device()" 2>/dev/null; then
    echo "🔧 CUDA detected - using GPU mode"
    # Check if sageattention is installed and available
    if python3 -c "import sageattention" 2>/dev/null; then
        echo "🔧 SageAttention detected - using optimized mode"
        python3 "$COMFYUI_DIR/main.py" --listen --use-sage-attention > "$LOG_FILE" 2>&1 &
    else
        python3 "$COMFYUI_DIR/main.py" --listen > "$LOG_FILE" 2>&1 &
    fi
else
    echo "💻 No CUDA detected - using CPU mode"
    python3 "$COMFYUI_DIR/main.py" --listen --cpu > "$LOG_FILE" 2>&1 &
fi

COMFYUI_PID=$!
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
    exit 1
fi

# Monitor processes and keep container alive
echo "✅ Setup complete. Monitoring services..."
while true; do
    # Check if ComfyUI is still running
    if ! kill -0 "$COMFYUI_PID" 2>/dev/null; then
        echo "❌ ComfyUI process died unexpectedly"
        echo "📋 Last 20 lines of log:"
        tail -n 20 "$LOG_FILE" 2>/dev/null || echo "No log file found"
        exit 1
    fi
    
    # Check if JupyterLab is still running
    if ! kill -0 "$JUPYTER_PID" 2>/dev/null; then
        echo "⚠️  JupyterLab process died, restarting..."
        jupyter-lab --ip=0.0.0.0 --allow-root --no-browser \
            --ServerApp.token='' --ServerApp.password='' \
            --ServerApp.allow_origin='*' --ServerApp.allow_credentials=True \
            --notebook-dir="$COMFYUI_DIR" &
        JUPYTER_PID=$!
    fi
    
    sleep 30
done