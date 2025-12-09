#!/bin/bash

set -e

echo "🎨 Mounting volumes..."

NETWORK_VOLUME="${NETWORK_VOLUME:-/workspace}"
COMFYUI_DIR="/ComfyUI"

mkdir -p "$NETWORK_VOLUME/cache/transformers"
mkdir -p "$NETWORK_VOLUME/cache/huggingface"

if [ -d "$COMFYUI_DIR" ] && [ -f "$COMFYUI_DIR/main.py" ]; then
    echo "✅ Using ComfyUI installation at $COMFYUI_DIR"
    
    if [ -d "$NETWORK_VOLUME/models" ]; then
        echo "📁 Found models directory in $NETWORK_VOLUME"
    else
        echo "📁 Moving models dir to $NETWORK_VOLUME"
        mv "$COMFYUI_DIR/models" "$NETWORK_VOLUME/models"
    fi
    
    if [ -d "$COMFYUI_DIR/models" ]; then
        echo "📁 Removing models dir from $COMFYUI_DIR"
        rm -rf "$COMFYUI_DIR/models"
    fi

    ln -sf "$NETWORK_VOLUME/models" "$COMFYUI_DIR/models"
    echo "✅ Models directory symlinked from $NETWORK_VOLUME/models to $COMFYUI_DIR/models"
else
    echo "❌ ComfyUI installation not found at $COMFYUI_DIR"
    exit 1
fi

if [ -d "/src/workflows" ]; then

    if [ -d "$NETWORK_VOLUME/workflows" ]; then
        echo "📁 Found workflows directory in $NETWORK_VOLUME"
    else
        echo "📁 Moving workflows dir to $NETWORK_VOLUME"
        mv "/src/workflows" "$NETWORK_VOLUME/workflows"
    fi
    
    if [ -d "$COMFYUI_DIR/user/default/workflows" ]; then
        echo "📁 Removing workflows dir from $COMFYUI_DIR"
        rm -rf "$COMFYUI_DIR/user/default/workflows"
    fi
    
    mkdir -p "$COMFYUI_DIR/user/default"

    ln -sf "$NETWORK_VOLUME/workflows" "$COMFYUI_DIR/user/default/workflows"
    echo "✅ Workflows symlinked from $NETWORK_VOLUME/workflows to $COMFYUI_DIR/user/default/workflows"
else
    echo "📁 No workflows mount found, using built-in workflows"
fi

echo "✅ Volumes mounted successfully"
