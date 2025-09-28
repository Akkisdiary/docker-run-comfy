#!/bin/bash

# Environment Setup Script
# Handles initial environment setup and additional_params.sh execution

set +e  # Don't exit on errors

echo "🌍 Setting up environment..."

# Execute additional setup script if present
if [ -f "/workspace/additional_params.sh" ]; then
    chmod +x /workspace/additional_params.sh
    echo "🔧 Executing additional_params.sh..."
    /workspace/additional_params.sh
else
    echo "ℹ️  No additional_params.sh found, continuing..."
fi

# Set up network volume and ComfyUI directory
export NETWORK_VOLUME="/workspace"
export COMFYUI_DIR="$NETWORK_VOLUME/ComfyUI"

# Ensure workspace directory exists
mkdir -p "$NETWORK_VOLUME"

echo "✅ Environment setup completed"
echo "📁 Network volume: $NETWORK_VOLUME"
echo "📁 ComfyUI directory: $COMFYUI_DIR"
