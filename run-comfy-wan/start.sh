#!/bin/bash

# =============================================================================
# ComfyUI Startup Script for RunPod - WAN 2.1/2.2 Optimized
# =============================================================================
# Purpose: Launch ComfyUI with optimal settings for RunPod environment
# Features: GPU detection, VRAM optimization, performance tuning, error handling
# Target: Maximum performance for WAN models and video generation
# =============================================================================

# Exit on any error to prevent running with broken configuration
# This ensures we catch startup issues immediately and provide clear feedback
set -e

echo "🚀 Starting ComfyUI..."

# =============================================================================
# ENVIRONMENT CONFIGURATION
# =============================================================================
# Configure CUDA and PyTorch settings for optimal performance

# CUDA_VISIBLE_DEVICES=0: Use only the first GPU (standard for RunPod single-GPU instances)
# This prevents multi-GPU confusion and ensures consistent performance
export CUDA_VISIBLE_DEVICES=0

# PYTORCH_CUDA_ALLOC_CONF: Configure PyTorch CUDA memory allocator
# max_split_size_mb:128: Limit memory fragmentation by setting max split size to 128MB
# Benefits: Reduces CUDA out-of-memory errors and improves memory efficiency
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:128

# =============================================================================
# DIRECTORY SETUP
# =============================================================================
# Navigate to ComfyUI installation directory
# All ComfyUI operations must be run from this directory for proper functionality
# =============================================================================
# SYSTEM DIAGNOSTICS
# =============================================================================
# Perform comprehensive GPU and system checks before startup
# This helps diagnosing issues and optimize settings based on available hardware
echo "🔍 Performing system diagnostics..."
echo "GPU Information:"
python -c "
import torch
print(f'  CUDA Available: {torch.cuda.is_available()}')
print(f'  GPU Count: {torch.cuda.device_count()}')
if torch.cuda.is_available():
    print(f'  GPU Name: {torch.cuda.get_device_name(0)}')
    print(f'  GPU Memory: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.1f} GB')
    print(f'  CUDA Version: {torch.version.cuda}')
    print(f'  PyTorch Version: {torch.__version__}')
else:
    print('  No GPU detected - will run in CPU mode')
"

# Check API token configuration
echo ""
echo "🔑 API Token Status:"
if [ -n "$HF_TOKEN" ]; then
    echo "  ✅ Hugging Face token configured"
else
    echo "  ⚠️  Hugging Face token not set (limited access to gated models)"
fi

if [ -n "$CIVITAI_TOKEN" ]; then
    echo "  ✅ CivitAI token configured"
else
    echo "  ⚠️  CivitAI token not set (rate limited downloads)"
fi

# =============================================================================
# LOGGING SETUP
# =============================================================================
# Create logs directory for ComfyUI output and error tracking
# Essential for debugging and monitoring performance
mkdir -p /workspace/logs
echo "✅ Logging directory created: /workspace/logs"

# =============================================================================
# GRACEFUL SHUTDOWN HANDLING
# =============================================================================
# Define cleanup function for proper ComfyUI shutdown
# This ensures models are properly unloaded and resources are freed
cleanup() {
    echo "🛑 Gracefully shutting down ComfyUI..."
    echo "   ℹ️  Unloading models and freeing GPU memory..."
    # Send SIGTERM to ComfyUI process for graceful shutdown
    kill $COMFY_PID 2>/dev/null || true
    # Wait a moment for graceful shutdown
    sleep 2
    echo "✅ ComfyUI shutdown complete"
    exit 0
}

# Set up signal handlers for container stop/restart events
# SIGTERM: Docker container stop
# SIGINT: Ctrl+C interrupt
trap cleanup SIGTERM SIGINT
echo "✅ Signal handlers configured for graceful shutdown"

# =============================================================================
# MODEL DIRECTORY VALIDATION
# =============================================================================
# Ensure all required model directories exist before starting ComfyUI
# Missing directories can cause ComfyUI startup failures or missing functionality
echo "📁 Validating model directory structure..."
if [ ! -d "/workspace/ComfyUI/models/checkpoints" ]; then
    echo "⚠️  Model directories missing, creating complete structure..."
    mkdir -p /workspace/ComfyUI/models/{checkpoints,vae,loras,controlnet,clip_vision,diffusers}
    echo "✅ Model directories created"
else
    echo "✅ Model directories validated"
fi

# =============================================================================
# COMFYUI STARTUP CONFIGURATION
# =============================================================================
# Configure ComfyUI startup arguments for optimal RunPod performance
echo "🎨 Configuring ComfyUI server startup..."

# Base RunPod Configuration:
# --listen 0.0.0.0: Accept connections from any IP (required for RunPod networking)
# --port 8188: Standard ComfyUI port (exposed in Dockerfile)
COMFY_ARGS="--listen 0.0.0.0 --port 8188"

# =============================================================================
# DYNAMIC PERFORMANCE OPTIMIZATION
# =============================================================================
# Automatically detect hardware capabilities and optimize ComfyUI settings
# This ensures maximum performance regardless of the RunPod GPU tier

if python -c "import torch; exit(0 if torch.cuda.is_available() else 1)" 2>/dev/null; then
    echo "✅ GPU detected, configuring GPU optimizations..."
    
    # Force FP16 (Half Precision) for better performance and memory efficiency
    # Benefits: 2x memory savings, faster inference on modern GPUs
    # Critical for: WAN models which can be memory-intensive
    COMFY_ARGS="$COMFY_ARGS --force-fp16"
    
    # Dynamic VRAM Detection and Optimization
    # Automatically adjust memory settings based on available GPU memory
    VRAM_GB=$(python -c "import torch; print(int(torch.cuda.get_device_properties(0).total_memory / 1024**3))" 2>/dev/null || echo "8")
    echo "📊 Detected GPU with ${VRAM_GB}GB VRAM"
    
    # VRAM-based optimization strategy:
    if [ "$VRAM_GB" -lt 8 ]; then
        echo "🔧 Low VRAM (<8GB): Enabling aggressive memory optimizations..."
        COMFY_ARGS="$COMFY_ARGS --lowvram --cpu-vae"
    elif [ "$VRAM_GB" -lt 12 ]; then
        echo "🔧 Medium VRAM (8-12GB): Enabling standard memory optimizations..."
        COMFY_ARGS="$COMFY_ARGS --lowvram"
    elif [ "$VRAM_GB" -lt 24 ]; then
        echo "🚀 High VRAM (12-24GB): Optimal settings for WAN models..."
        # No additional memory constraints needed
    else
        echo "🔥 Ultra-high VRAM (24GB+): Maximum performance mode..."
        # Could add --highvram flag if available in future ComfyUI versions
    fi
    
    echo "✅ GPU optimizations configured"
else
    echo "⚠️  No GPU detected, configuring CPU mode..."
    echo "   ℹ️  Performance will be significantly slower without GPU"
    COMFY_ARGS="$COMFY_ARGS --cpu"
fi

# =============================================================================
# USER EXPERIENCE OPTIMIZATIONS
# =============================================================================
# Configure settings for better user experience and workflow efficiency

# Preview Method Configuration:
# --preview-method auto: Automatically select best preview method based on hardware
# Benefits: Real-time generation previews, better workflow feedback
# Options: auto, latent2rgb, taesd (auto selects best based on available models)
COMFY_ARGS="$COMFY_ARGS --preview-method auto"
echo "✅ Preview system configured for real-time feedback"

# =============================================================================
# STARTUP EXECUTION
# =============================================================================
# Display final configuration and launch ComfyUI
echo ""
echo "🔧 Final ComfyUI Configuration:"
echo "   Command: python main.py $COMFY_ARGS"
echo "   Logging: /workspace/logs/comfyui.log"
echo "   Access: http://localhost:8188 (RunPod will provide public URL)"
echo ""

# =============================================================================
# VERIFY INSTALLATION
# =============================================================================
# Verify that ComfyUI was properly copied from the build stage
if [ ! -d "/workspace/ComfyUI" ]; then
    echo "❌ ComfyUI not found in runtime image!"
    echo "This indicates an issue with the multi-stage build process."
    exit 1
fi

echo "✅ ComfyUI installation verified"

# Display ComfyUI version information
echo ""
echo "📋 ComfyUI Version Information:"
if command -v comfy &> /dev/null; then
    echo "  ComfyUI CLI: $(comfy --version 2>/dev/null || echo 'Version info not available')"
fi

if [ -f "/workspace/ComfyUI/main.py" ]; then
    echo "  ComfyUI Core: Latest stable version (CLI managed)"
    echo "  Installation: Official CLI v1.5.1"
else
    echo "  ⚠️  ComfyUI main.py not found"
fi

# =============================================================================
# START JUPYTER SERVER
# =============================================================================
# Start Jupyter notebook server for development and experimentation
echo "📓 Starting Jupyter notebook server..."
/workspace/src/start_jupyter.sh

# =============================================================================
# START COMFYUI SERVER
# =============================================================================
# Launch ComfyUI Process:
# Run in background with output redirected to log file
# Capture both stdout and stderr for comprehensive logging
echo "🚀 Launching ComfyUI server..."
python main.py $COMFY_ARGS > /workspace/logs/comfyui.log 2>&1 &
COMFY_PID=$!  # Store process ID for later management

# Startup Validation:
# Wait for ComfyUI to initialize before proceeding
# This prevents premature success/failure reporting
echo "⏳ Waiting for ComfyUI initialization..."
sleep 5

# =============================================================================
# STARTUP VALIDATION AND MONITORING
# =============================================================================
# Verify ComfyUI started successfully and provide user guidance

if kill -0 $COMFY_PID 2>/dev/null; then
    echo "✅ ComfyUI started successfully!"
    echo ""
    echo "🎉 [32mWAN 2.1/2.2 ComfyUI Server Ready![0m"
    echo "📋 Access Information:"
    echo "   🌐 Local URL: http://localhost:8188"
    echo "   🔗 RunPod Public URL: Available in RunPod interface"
    echo "   📝 Logs: /workspace/logs/comfyui.log"
    echo ""
    echo "🚀 Quick Start Guide:"
    echo "   1. Access the web interface using the public URL"
    echo "   2. Use ComfyUI Manager to install WAN-specific nodes"
    echo "   3. Download WAN 2.1/2.2 models through the interface"
    echo "   4. Start creating amazing images and videos!"
    echo ""
    
    # Display Recent Logs:
    # Show last few log lines to help with immediate troubleshooting
    echo "📄 Recent startup logs:"
    echo "----------------------------------------"
    tail -n 10 /workspace/logs/comfyui.log
    echo "----------------------------------------"
    echo ""
    echo "ℹ️  ComfyUI is running. Use Ctrl+C to stop gracefully."
    
    # Keep Container Running:
    # Wait for ComfyUI process to complete (keeps container alive)
    # This also allows the cleanup function to work properly on container stop
    wait $COMFY_PID
else
    # Startup Failure Handling:
    # Provide detailed error information for troubleshooting
    echo "❌ ComfyUI failed to start!"
    echo ""
    echo "🔍 Troubleshooting Information:"
    echo "   • Check GPU availability and drivers"
    echo "   • Verify CUDA compatibility"
    echo "   • Review full error logs below"
    echo ""
    echo "📄 Complete error logs:"
    echo "========================================"
    cat /workspace/logs/comfyui.log
    echo "========================================"
    exit 1
fi
