#!/bin/bash

# Main Startup Script - Orchestrates all setup and service startup
# This is the main entry point that coordinates all other scripts

set +e  # Don't exit on errors

echo "🚀 Starting ComfyUI Container Setup"
echo "===================================="

# Get script directory for relative imports
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# STEP: Environment Setup
echo "📋 STEP: Environment Setup"
source "$SCRIPT_DIR/setup_environment.sh"
if [ $? -ne 0 ]; then
    echo "❌ Environment setup failed"
    exit 1
fi

# STEP: SageAttention Installation in Background
echo "📋 STEP: SageAttention Installation"
source "$SCRIPT_DIR/install_sageattention.sh"
install_sageattention_bg

# STEP: ComfyUI Setup (runs in parallel with SageAttention installation)
echo "📋 STEP: ComfyUI Setup"
source "$SCRIPT_DIR/setup_comfyui.sh"
if [ $? -ne 0 ]; then
    echo "❌ ComfyUI setup failed"
    exit 1
fi

# STEP: Start JupyterLab (immediate access)
echo "📋 STEP: Starting JupyterLab"
source "$SCRIPT_DIR/start_jupyter.sh"
if [ $? -ne 0 ]; then
    echo "❌ JupyterLab startup failed"
    exit 1
fi

# STEP 5: Start Model Downloads (parallel with SageAttention)
echo "📋 STEP: Starting Default Model Downloads"
source "$SCRIPT_DIR/download_models.sh"
download_models

# STEP: Wait for SageAttention Installation
echo "📋 STEP: Finalizing SageAttention Installation"
wait_for_sageattention

# STEP: Wait for Model Downloads
echo "📋 STEP: Waiting for Model Downloads"
wait_for_downloads

# STEP: Start ComfyUI (after models are ready)
echo "📋 STEP: Starting ComfyUI"
source "$SCRIPT_DIR/start_comfyui.sh" &
COMFYUI_STARTUP_PID=$!
echo "📦 ComfyUI startup running in background (PID: $COMFYUI_STARTUP_PID)"

# Wait for ComfyUI startup to complete
echo "⏳ Waiting for ComfyUI startup to complete..."
wait $COMFYUI_STARTUP_PID
if [ $? -ne 0 ]; then
    echo "❌ ComfyUI startup failed"
    exit 1
fi

# STEP: Monitor Services
echo "📋 STEP: Service Monitoring"
source "$SCRIPT_DIR/monitor_services.sh"
