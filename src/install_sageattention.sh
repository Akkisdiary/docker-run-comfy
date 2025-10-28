#!/bin/bash

set -e

if python3 -c "import sageattention" 2>/dev/null; then
    echo "✅ SageAttention already installed"
    return 0
fi

if python3 -c "import torch; torch.cuda.current_device()" 2>/dev/null; then
    echo "🚀 CUDA detected - installing SageAttention for optimal performance..."

    if pip install git+https://github.com/thu-ml/SageAttention.git > /tmp/sageattention_install.log 2>&1; then
        echo "✅ SageAttention installed successfully" >> /tmp/sageattention_install.log
    else
        echo "⚠️  SageAttention installation failed, continuing with standard mode" >> /tmp/sageattention_install.log
        echo "    This is normal if GPU architecture is not supported" >> /tmp/sageattention_install.log
    fi

else
    echo "💻 No CUDA detected - skipping SageAttention installation"
fi