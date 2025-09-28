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

echo "✅ ComfyUI setup completed"
