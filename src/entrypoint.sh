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

# Step 5: Start Services (JupyterLab and ComfyUI)
echo "📋 Step 5: Starting Services"
source "$SCRIPT_DIR/start_services.sh"
if [ $? -ne 0 ]; then
    echo "❌ Services startup failed"
    exit 1
fi

# Step 6: Monitor Services
echo "📋 Step 6: Service Monitoring"
source "$SCRIPT_DIR/monitor_services.sh"
