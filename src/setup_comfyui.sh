#!/bin/bash

# ComfyUI Setup Script
# Handles ComfyUI installation, workflows, and directory setup

set +e  # Don't exit on errors

echo "🎨 Setting up ComfyUI..."

# Use environment variables from setup_environment.sh
NETWORK_VOLUME="${NETWORK_VOLUME:-/workspace}"
COMFYUI_DIR="${COMFYUI_DIR:-$NETWORK_VOLUME/ComfyUI}"

# Handle ComfyUI installation based on network volume state
if [ ! -f "$COMFYUI_DIR/main.py" ]; then
    echo "📦 ComfyUI not found in $NETWORK_VOLUME, installing fresh copy..."
    
    # Check if ComfyUI exists in container (from Docker build)
    if [ -d "/ComfyUI" ] && [ -f "/ComfyUI/main.py" ]; then
        # Move entire ComfyUI installation to network volume
        echo "📁 Moving ComfyUI from container build..."
        mv /ComfyUI "$COMFYUI_DIR"
        echo "✅ ComfyUI moved to $NETWORK_VOLUME"
    else
        # Install ComfyUI directly to network volume
        echo "📦 Installing ComfyUI directly to network volume..."
        cd "$NETWORK_VOLUME"
        /usr/bin/yes | comfy --workspace "$NETWORK_VOLUME" install
        
        if [ -f "$COMFYUI_DIR/main.py" ]; then
            echo "✅ ComfyUI installed to $NETWORK_VOLUME"
        else
            echo "❌ ComfyUI installation failed"
            exit 1
        fi
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

echo "✅ ComfyUI setup completed"
