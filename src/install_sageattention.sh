#!/bin/bash

set -e

if python3 -c "import sageattention" 2>/dev/null; then
    echo "✅ SageAttention already installed"
    return 0
fi

if python3 -c "import torch; torch.cuda.current_device()" 2>/dev/null; then
    echo "🚀 CUDA detected - installing SageAttention for optimal performance..."

    pip install git+https://github.com/thu-ml/SageAttention.git
    echo "✅ SageAttention installed successfully"
else
    echo "💻 No CUDA detected - skipping SageAttention installation"
fi