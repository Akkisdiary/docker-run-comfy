#!/bin/bash

# SageAttention Installation Script
# Handles SageAttention installation in background for optimal performance

set +e  # Don't exit on errors

# Function to install SageAttention in background
install_sageattention_bg() {
    echo "🔧 Starting SageAttention installation in background..."
    
    # Check if SageAttention is already installed
    if python3 -c "import sageattention" 2>/dev/null; then
        echo "✅ SageAttention already installed"
        return 0
    fi
    
    # Check if CUDA is available for compilation
    if python3 -c "import torch; torch.cuda.current_device()" 2>/dev/null; then
        echo "🚀 CUDA detected - installing SageAttention for optimal performance..."
        
        # Install SageAttention with proper error handling in background
        (
            if pip install git+https://github.com/thu-ml/SageAttention.git > /tmp/sageattention_install.log 2>&1; then
                echo "✅ SageAttention installed successfully" >> /tmp/sageattention_install.log
                touch /tmp/sageattention_success
            else
                echo "⚠️  SageAttention installation failed, continuing with standard mode" >> /tmp/sageattention_install.log
                echo "    This is normal if GPU architecture is not supported" >> /tmp/sageattention_install.log
                touch /tmp/sageattention_failed
            fi
        ) &
        
        # Store the background process ID
        export SAGEATTENTION_PID=$!
        echo "📦 SageAttention installation started in background (PID: $SAGEATTENTION_PID)"
    else
        echo "💻 No CUDA detected - skipping SageAttention installation"
    fi
}

# Function to wait for SageAttention installation to complete
wait_for_sageattention() {
    if [ -n "$SAGEATTENTION_PID" ]; then
        echo "⏳ Waiting for SageAttention installation to complete..."
        wait $SAGEATTENTION_PID 2>/dev/null || true
        
        # Check installation result
        if [ -f "/tmp/sageattention_success" ]; then
            echo "✅ SageAttention installation completed successfully"
            rm -f /tmp/sageattention_success /tmp/sageattention_install.log
        elif [ -f "/tmp/sageattention_failed" ]; then
            echo "⚠️  SageAttention installation failed (see details above)"
            rm -f /tmp/sageattention_failed /tmp/sageattention_install.log
        fi
    fi
}

# Export functions for use in other scripts
export -f install_sageattention_bg
export -f wait_for_sageattention

# Start installation if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_sageattention_bg
fi
