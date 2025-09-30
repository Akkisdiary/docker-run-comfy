#!/bin/bash

set +e

echo "🚀 Starting ComfyUI Container Setup"
echo "===================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📋 STEP: Environment Setup"
source "$SCRIPT_DIR/setup_environment.sh"
if [ $? -ne 0 ]; then
    echo "❌ Environment setup failed"
    exit 1
fi

echo "📋 STEP: SageAttention Installation"
source "$SCRIPT_DIR/install_sageattention.sh"
install_sageattention_bg
echo "📋 STEP: ComfyUI Setup"
source "$SCRIPT_DIR/setup_comfyui.sh"
if [ $? -ne 0 ]; then
    echo "❌ ComfyUI setup failed"
    exit 1
fi

echo "📋 STEP: Starting JupyterLab"
source "$SCRIPT_DIR/start_jupyter.sh"
if [ $? -ne 0 ]; then
    echo "❌ JupyterLab startup failed"
    exit 1
fi

echo "📋 STEP: Starting Default Model Downloads"
source "$SCRIPT_DIR/download_models.sh"
download_models

echo "📋 STEP: Finalizing SageAttention Installation"
wait_for_sageattention

echo "📋 STEP: Waiting for Model Downloads"
wait_for_downloads

echo "📋 STEP: Starting ComfyUI"
source "$SCRIPT_DIR/start_comfyui.sh"

echo "📋 STEP: Service Monitoring"
export COMFYUI_PID
export JUPYTER_PID
source "$SCRIPT_DIR/monitor_services.sh"
