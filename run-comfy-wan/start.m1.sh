#!/bin/bash
# ComfyUI Startup Script for M1 Mac Testing (CPU Mode)
# Purpose: Start ComfyUI on M1 Mac without CUDA dependencies

set -e

echo "🍎 Starting ComfyUI on M1 Mac (CPU mode)..."
cd /workspace/ComfyUI

# Create logs directory
mkdir -p /workspace/logs
echo "✅ Logging directory created"

# Check system information
echo "🔍 System Information:"
echo "  Platform: $(uname -m)"
echo "  Python: $(python --version)"
python -c "
import torch
print(f'  PyTorch: {torch.__version__}')
print(f'  CPU Threads: {torch.get_num_threads()}')
print(f'  MPS Available: {torch.backends.mps.is_available() if hasattr(torch.backends, \"mps\") else \"Not supported\"}')
"

# Graceful shutdown function
cleanup() {
    echo "🛑 Shutting down ComfyUI..."
    kill $COMFY_PID 2>/dev/null || true
    sleep 2
    echo "✅ ComfyUI shutdown complete"
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT
echo "✅ Signal handlers configured"

# Validate model directories
echo "📁 Validating model directories..."
if [ ! -d "/workspace/ComfyUI/models/checkpoints" ]; then
    echo "⚠️  Model directories missing, creating..."
    mkdir -p /workspace/ComfyUI/models/{checkpoints,vae,loras,controlnet,clip_vision,diffusers}
    echo "✅ Model directories created"
else
    echo "✅ Model directories validated"
fi

# Configure ComfyUI for CPU mode
echo "🎨 Configuring ComfyUI for CPU mode..."
COMFY_ARGS="--listen 0.0.0.0 --port 8188 --cpu"

# Add preview method
COMFY_ARGS="$COMFY_ARGS --preview-method auto"

echo ""
echo "🔧 ComfyUI Configuration:"
echo "   Mode: CPU-only (M1 Mac)"
echo "   Logging: /workspace/logs/comfyui.log"
echo "   Access: http://localhost:8188"
echo ""

# Start Jupyter in background
echo "📓 Starting Jupyter notebook server..."
/workspace/src/start_jupyter.sh &

# Start ComfyUI
echo "🚀 Launching ComfyUI server..."
python main.py $COMFY_ARGS > /workspace/logs/comfyui.log 2>&1 &
COMFY_PID=$!

# Wait for startup
echo "⏳ Waiting for ComfyUI initialization..."
sleep 5

# Check if started successfully
if kill -0 $COMFY_PID 2>/dev/null; then
    echo "✅ ComfyUI started successfully!"
    echo ""
    echo "🎉 ComfyUI Server Ready (CPU Mode)"
    echo "📋 Access Information:"
    echo "   🌐 Local URL: http://localhost:8188"
    echo "   📝 Logs: /workspace/logs/comfyui.log"
    echo ""
    echo "⚠️  Performance Notes for M1 Mac:"
    echo "   • CPU-only mode will be slower than GPU"
    echo "   • Use smaller models for faster generation"
    echo "   • Consider lower resolution for testing"
    echo ""
    echo "📄 Recent startup logs:"
    echo "----------------------------------------"
    tail -n 10 /workspace/logs/comfyui.log
    echo "----------------------------------------"
    echo ""
    echo "ℹ️  ComfyUI is running. Use Ctrl+C to stop."
    
    # Keep container running
    wait $COMFY_PID
else
    echo "❌ ComfyUI failed to start!"
    echo ""
    echo "📄 Error logs:"
    echo "========================================"
    cat /workspace/logs/comfyui.log
    echo "========================================"
    exit 1
fi
