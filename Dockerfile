# =============================================================================
# RunPod Vanilla ComfyUI Template - Multi-Stage Docker Build
# =============================================================================
# Purpose: High-performance ComfyUI setup with CUDA 12.8 optimization
# Architecture: Multi-stage build for optimized image size and performance
# Target: RunPod deployment with GPU acceleration
# =============================================================================

# =============================================================================
# STAGE 1: BUILD ENVIRONMENT
# =============================================================================
# This stage handles all build-time dependencies, ComfyUI installation, and Jupyter setup
FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04 AS builder

# Build Environment Variables:
# Configure environment for optimal build performance
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# Working Directory:
# Set up build workspace
WORKDIR /build

# Install Build Dependencies:
# Install Python 3.11 and essential build tools
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python3-pip \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    unzip \
    libgl1-mesa-dev \
    libglib2.0-dev \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    ffmpeg \
    libavcodec-extra \
    && rm -rf /var/lib/apt/lists/*

# Set up Python 3.11 as default python
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Copy and Install Python Dependencies:
# Install all Python packages needed for ComfyUI production
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Install ComfyUI using official CLI (comfy-cli already installed via requirements.txt)
RUN comfy --workspace /build/ComfyUI --skip-prompt install --version latest --nvidia --cuda-version 12.8

# Verify installations
RUN ls -la /build/ComfyUI && echo "ComfyUI installation verified" \
    && jupyter --version && echo "Jupyter installation verified"

# =============================================================================
# STAGE 2: RUNTIME ENVIRONMENT
# =============================================================================
# Lightweight runtime stage that only contains what's needed to run the services
FROM nvidia/cuda:12.8.1-cudnn-runtime-ubuntu24.04 AS runtime

# Runtime Environment Variables:
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# Working Directory:
WORKDIR /workspace

# Install Minimal Runtime Dependencies:
# Only install what's absolutely necessary for runtime
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3-pip \
    curl \
    wget \
    libgl1-mesa-dri \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    ffmpeg \
    libavcodec-extra \
    && rm -rf /var/lib/apt/lists/*

# Set up Python 3.11 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
# Copy Python Environment from Builder:
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy Runtime Scripts:
# Copy startup and utility scripts from builder stage
COPY --from=builder /build/ComfyUI /workspace/ComfyUI
COPY run-comfy-wan/ /workspace/run-comfy-wan/
RUN chmod +x /workspace/run-comfy-wan/*.sh

# Create Directory Structure:
RUN mkdir -p /workspace/ComfyUI/models/checkpoints \
    && mkdir -p /workspace/ComfyUI/models/vae \
    && mkdir -p /workspace/ComfyUI/models/controlnet \
    && mkdir -p /workspace/ComfyUI/models/diffusers \
    && mkdir -p /workspace/ComfyUI/custom_nodes \
    && mkdir -p /workspace/ComfyUI/input \
    && mkdir -p /workspace/ComfyUI/output \
    && mkdir -p /workspace/logs \
    && ln -sf /workspace/ComfyUI/models /workspace/models \
    && ln -sf /workspace/ComfyUI/input /workspace/input \
    && ln -sf /workspace/ComfyUI/output /workspace/output

# Model Caching Configuration:
ENV TRANSFORMERS_CACHE=/workspace/cache/transformers
ENV HF_HOME=/workspace/cache/huggingface
RUN mkdir -p $TRANSFORMERS_CACHE $HF_HOME

# API Token Configuration:
ENV HF_TOKEN=""
ENV CIVITAI_TOKEN=""

# Set Permissions:
RUN chmod -R 755 /workspace/ComfyUI \
    && chown -R root:root /workspace

# Expose Ports:
EXPOSE 8188 8888

# Container Startup Command:
# The start script will handle all service initialization
CMD ["/workspace/run-comfy-wan/start.sh"]

# =============================================================================
# MULTI-STAGE BUILD BENEFITS
# =============================================================================
# Benefits of this multi-stage approach:
# 1. Smaller final image size (no build tools in runtime)
# 2. Faster deployment and startup times
# 3. Better security (fewer packages in production image)
# 4. Cleaner separation of build and runtime concerns
# 5. Optimized layer caching for faster rebuilds
# =============================================================================
