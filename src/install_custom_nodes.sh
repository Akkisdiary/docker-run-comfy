#!/bin/bash

# Custom Nodes Installation Script for ComfyUI
# This script installs custom nodes from git repositories with automatic dependency handling

set -e  # Exit on any error

echo "🔧 ComfyUI Custom Nodes Installation Script"
echo "============================================="

# Configuration
COMFYUI_DIR="/ComfyUI"
CUSTOM_NODES_DIR="$COMFYUI_DIR/custom_nodes"

# List of custom node git URLs to install
# Add/remove URLs as needed for your use case
CUSTOM_NODE_URLS=(
    # Image processing
    "https://github.com/rgthree/rgthree-comfy.git"
    "https://github.com/city96/ComfyUI-GGUF"
    "https://github.com/giriss/comfy-image-saver"
    "https://github.com/ClownsharkBatwing/RES4LYF"
)

# Helper function to install a single custom node
install_custom_node() {
    local repo_url="$1"
    local repo_name=$(basename "$repo_url" .git)
    local node_dir="$CUSTOM_NODES_DIR/$repo_name"
    
    echo ""
    echo "📦 Installing: $repo_name"
    echo "   URL: $repo_url"
    
    # Skip if already exists
    if [ -d "$node_dir" ]; then
        echo "   ⚠️  Already exists, skipping..."
        return 0
    fi
    
    # Clone the repository
    echo "   📥 Cloning repository..."
    if ! git clone "$repo_url" "$node_dir"; then
        echo "   ❌ Failed to clone $repo_url"
        echo "   🚨 This is a critical error - failing build"
        exit 1
    fi
    
    cd "$node_dir"
    
    # Check for and run install.py if it exists
    if [ -f "install.py" ]; then
        echo "   🐍 Running install.py..."
        if python install.py; then
            echo "   ✅ install.py completed successfully"
        else
            echo "   ❌ install.py failed for $repo_name"
            echo "   🚨 This is a critical error - failing build"
            exit 1
        fi
    fi
    
    # Check for and install requirements.txt if it exists
    if [ -f "requirements.txt" ]; then
        echo "   📋 Installing requirements.txt..."
        if pip install -r requirements.txt; then
            echo "   ✅ requirements.txt installed successfully"
        else
            echo "   ❌ requirements.txt installation failed for $repo_name"
            echo "   🚨 This is a critical error - failing build"
            exit 1
        fi
    fi
    
    # Check for alternative requirement files
    for req_file in "requirements.txt" "requirements-dev.txt" "requirements-optional.txt"; do
        if [ -f "$req_file" ] && [ "$req_file" != "requirements.txt" ]; then
            echo "   📋 Found additional requirements: $req_file"
            if pip install -r "$req_file"; then
                echo "   ✅ $req_file installed successfully"
            else
                echo "   ⚠️  $req_file installation failed, continuing anyway..."
            fi
        fi
    done
    
    # Check for setup.py
    if [ -f "setup.py" ]; then
        echo "   🔧 Running setup.py install..."
        if python setup.py install; then
            echo "   ✅ setup.py completed successfully"
        else
            echo "   ❌ setup.py failed for $repo_name"
            echo "   🚨 This is a critical error - failing build"
            exit 1
        fi
    fi
    
    # Check for pyproject.toml (modern Python packaging)
    if [ -f "pyproject.toml" ]; then
        echo "   📦 Installing with pip (pyproject.toml found)..."
        if pip install -e . 2>/dev/null; then
            echo "   ✅ pip install completed successfully"
        else
            echo "   ⚠️  pip install failed, trying alternative installation..."
            # Try installing without editable mode
            if pip install . 2>/dev/null; then
                echo "   ✅ pip install (non-editable) completed successfully"
            else
                echo "   ❌ pip install failed for $repo_name"
                echo "   🚨 This is a critical error - failing build"
                exit 1
            fi
        fi
    fi
    
    echo "   ✅ $repo_name installation completed"
    cd - > /dev/null
    return 0
}

# Main installation function
install_all_custom_nodes() {
    echo "🚀 Starting custom nodes installation..."
    echo "📁 Custom nodes directory: $CUSTOM_NODES_DIR"
    
    # Ensure custom_nodes directory exists
    mkdir -p "$CUSTOM_NODES_DIR"
    
    # Install each custom node
    local success_count=0
    local total_count=${#CUSTOM_NODE_URLS[@]}
    
    for repo_url in "${CUSTOM_NODE_URLS[@]}"; do
        if install_custom_node "$repo_url"; then
            ((success_count++))
        fi
    done
    
    echo ""
    echo "📊 Installation Summary:"
    echo "   Total nodes: $total_count"
    echo "   Successfully installed: $success_count"
    echo "   Failed: $((total_count - success_count))"
    
    if [ $success_count -eq $total_count ]; then
        echo "🎉 All custom nodes installed successfully!"
    else
        echo "⚠️  Some custom nodes failed to install, but ComfyUI should still work"
    fi
}

# Function to list installed custom nodes
list_installed_nodes() {
    echo ""
    echo "📋 Installed Custom Nodes:"
    echo "=========================="
    
    if [ -d "$CUSTOM_NODES_DIR" ]; then
        for node_dir in "$CUSTOM_NODES_DIR"/*; do
            if [ -d "$node_dir" ]; then
                local node_name=$(basename "$node_dir")
                echo "   ✅ $node_name"
            fi
        done
    else
        echo "   No custom nodes directory found"
    fi
}

# Function to clean up failed installations
cleanup_failed_installs() {
    echo "🧹 Cleaning up any incomplete installations..."
    
    if [ -d "$CUSTOM_NODES_DIR" ]; then
        find "$CUSTOM_NODES_DIR" -type d -empty -delete 2>/dev/null || true
    fi
}

# Main execution
main() {
    echo "Starting at: $(date)"
    
    # Check if ComfyUI directory exists
    if [ ! -d "$COMFYUI_DIR" ]; then
        echo "❌ ComfyUI directory not found at $COMFYUI_DIR"
        echo "   Make sure ComfyUI is installed first"
        echo "   Continuing anyway in case ComfyUI is installed elsewhere..."
    fi
    
    # Install all custom nodes (fail on any critical error)
    install_all_custom_nodes
    
    # Clean up any failed installations
    cleanup_failed_installs
    
    # List what was installed
    list_installed_nodes
    
    echo ""
    echo "✅ Custom nodes installation completed at: $(date)"
    echo "🚀 ComfyUI setup finished!"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
