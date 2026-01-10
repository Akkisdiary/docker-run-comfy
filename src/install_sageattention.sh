#!/bin/bash

set -e

if python3 -c "import sageattention" 2>/dev/null; then
    echo "✅ SageAttention already installed"
    return 0
fi

if python3 -c "import torch; torch.cuda.current_device()" 2>/dev/null; then
    echo "🚀 CUDA detected - installing SageAttention for optimal performance..."

    pip3 install sageattention==2.2.0 --no-build-isolation
    echo "✅ SageAttention installed successfully"
else
    echo "💻 No CUDA detected - skipping SageAttention installation"
fi
