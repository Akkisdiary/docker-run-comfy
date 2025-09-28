#!/bin/bash

# Main Startup Script - Orchestrates all setup and service startup
# This is the main entry point that coordinates all other scripts

set +e  # Don't exit on errors

echo "🚀 Starting ComfyUI Container Setup"
echo "===================================="

# Get script directory for relative imports
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Step 1: Environment Setup
echo "📋 Step 1: Environment Setup"
source "$SCRIPT_DIR/setup_environment.sh"
if [ $? -ne 0 ]; then
    echo "❌ Environment setup failed"
    exit 1
fi

# Step 2: Start SageAttention Installation in Background
echo "📋 Step 2: Starting SageAttention Installation"
source "$SCRIPT_DIR/install_sageattention.sh"
install_sageattention_bg

# Step 3: ComfyUI Setup (runs in parallel with SageAttention installation)
echo "📋 Step 3: ComfyUI Setup"
source "$SCRIPT_DIR/setup_comfyui.sh"
if [ $? -ne 0 ]; then
    echo "❌ ComfyUI setup failed"
    exit 1
fi

# Step 4: Wait for SageAttention Installation
echo "📋 Step 4: Finalizing SageAttention Installation"
wait_for_sageattention

# Step 5: Start JupyterLab (immediate access)
echo "📋 Step 5: Starting JupyterLab"
source "$SCRIPT_DIR/start_jupyter.sh"
if [ $? -ne 0 ]; then
    echo "❌ JupyterLab startup failed"
    exit 1
fi

# Step 6: Start ComfyUI (in background for parallel startup)
echo "📋 Step 6: Starting ComfyUI"
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

# Step 7: Monitor Services
echo "📋 Step 7: Service Monitoring"
source "$SCRIPT_DIR/monitor_services.sh"
