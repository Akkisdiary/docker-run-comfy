#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔧 Starting ComfyUI Container"

if [ -f "/workspace/additional_params.sh" ]; then
    chmod +x /workspace/additional_params.sh
    echo "Executing additional_params.sh..."
    /workspace/additional_params.sh
else
    echo "No additional_params.sh found"
fi

source "$SCRIPT_DIR/start_jupyter.sh"
if [ $? -ne 0 ]; then
    echo "❌ JupyterLab startup failed"
    exit 1
fi

source "$SCRIPT_DIR/install_sageattention.sh"

source "$SCRIPT_DIR/mount_volume.sh"

source "$SCRIPT_DIR/download_models.sh"

source "$SCRIPT_DIR/start_comfyui.sh"

source "$SCRIPT_DIR/monitor_services.sh"
