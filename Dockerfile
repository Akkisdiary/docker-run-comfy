FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive \
   PIP_PREFER_BINARY=1 \
   PYTHONUNBUFFERED=1 \
   CMAKE_BUILD_PARALLEL_LEVEL=8

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        python3.12 python3.12-venv python3.12-dev \
        python3-pip \
        curl ffmpeg ninja-build git aria2 git-lfs wget vim \
        libgl1 libglib2.0-0 build-essential gcc && \
    \
    # make Python3.12 the default python & pip
    ln -sf /usr/bin/python3.12 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip && \
    \
    python3.12 -m venv /opt/venv && \
    \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Use the virtual environment
ENV PATH="/opt/venv/bin:$PATH"

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install torch==2.8.0+cu128 torchvision==0.23.0+cu128 torchaudio==2.8.0+cu128 \
        --index-url https://download.pytorch.org/whl/cu128

# Core Python tooling
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install packaging setuptools wheel

# Install Python packages with pip cache
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install comfy-cli jupyterlab jupyterlab-lsp \
        jupyter-server jupyter-server-terminals \
        ipykernel

# Install SageAttention 2.2.0 (SageAttention2++) for optimal performance
RUN --mount=type=cache,target=/root/.cache/pip \
    git clone https://github.com/thu-ml/SageAttention.git /tmp/SageAttention && \
    cd /tmp/SageAttention && \
    export EXT_PARALLEL=4 NVCC_APPEND_FLAGS="--threads 8" MAX_JOBS=32 && \
    pip install -e . && \
    rm -rf /tmp/SageAttention

# ComfyUI install
RUN --mount=type=cache,target=/root/.cache/pip \
    /usr/bin/yes | comfy --workspace /ComfyUI install

# Create directory for custom files (separate from network volume)
RUN mkdir -p /src
WORKDIR /src

COPY src/ .

RUN --mount=type=cache,target=/root/.cache/pip \
    ./install_custom_nodes.sh

EXPOSE 8188 8888

CMD ["./start_script.sh"]