#!/bin/bash

set -e

if python3 -c "import sageattention" 2>/dev/null; then
    echo "✅ SageAttention already installed"
    return 0
fi

if python3 -c "import torch; torch.cuda.current_device()" 2>/dev/null; then
    echo "🚀 CUDA detected - installing SageAttention for optimal performance..."

    export EXT_PARALLEL=4 NVCC_APPEND_FLAGS="--threads 8" MAX_JOBS=32
    cd /tmp
    git clone https://github.com/thu-ml/SageAttention.git
    cd SageAttention
    git reset --hard 68de379
    pip install -e .
    echo "✅ SageAttention installed successfully"
else
    echo "💻 No CUDA detected - skipping SageAttention installation"
fi
