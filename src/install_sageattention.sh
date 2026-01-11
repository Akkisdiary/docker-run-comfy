#!/bin/bash

set -e

if python3 -c "import sageattention" 2>/dev/null; then
    echo "✅ SageAttention already installed"
    return 0
fi

if python3 -c "import torch; torch.cuda.current_device()" 2>/dev/null; then
    echo "🚀 CUDA detected - installing SageAttention for optimal performance..."

    if [ -z "${CUDA_HOME:-}" ] && [ -d "/usr/local/cuda" ]; then
        export CUDA_HOME="/usr/local/cuda"
    fi

    if ! command -v nvcc >/dev/null 2>&1 && [ ! -d "${CUDA_HOME:-}" ]; then
        echo "💻 CUDA detected but CUDA toolkit not found (nvcc/CUDA_HOME) - skipping SageAttention installation"
        return 0
    fi

    TORCH_CUDA_ARCH_LIST="$(python3 - <<'PY' 2>/dev/null || true
import torch
maj, minr = torch.cuda.get_device_capability()
print(f"{maj}.{minr}")
PY
)"
    if [ -z "${TORCH_CUDA_ARCH_LIST}" ]; then
        TORCH_CUDA_ARCH_LIST="8.0;8.6;8.9;9.0"
    fi
    export TORCH_CUDA_ARCH_LIST

    if pip3 install --no-build-isolation git+https://github.com/thu-ml/SageAttention.git; then
        echo "✅ SageAttention installed successfully"
    else
        echo "⚠️ SageAttention installation failed - continuing without it"
        return 0
    fi
else
    echo "💻 No CUDA detected - skipping SageAttention installation"
fi
