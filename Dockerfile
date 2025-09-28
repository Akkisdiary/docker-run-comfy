FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive \
   PIP_PREFER_BINARY=1 \
   PYTHONUNBUFFERED=1 \
   CMAKE_BUILD_PARALLEL_LEVEL=8 \
   PIP_DISABLE_PIP_VERSION_CHECK=1 \
   PIP_NO_INPUT=1

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        python3.12 python3.12-venv python3.12-dev \
        python3-pip \
        curl ffmpeg ninja-build git jq aria2 git-lfs wget vim unzip \
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

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install comfy-cli jupyterlab jupyterlab-lsp \
        jupyter-server jupyter-server-terminals \
        ipykernel huggingface-hub opencv-python

RUN --mount=type=cache,target=/root/.cache/pip \
    /usr/bin/yes | comfy --workspace /ComfyUI install

RUN --mount=type=cache,target=/root/.cache/pip \
    for repo in \
        https://github.com/rgthree/rgthree-comfy.git \
        https://github.com/city96/ComfyUI-GGUF \
        https://github.com/ClownsharkBatwing/RES4LYF \
        https://github.com/giriss/comfy-image-saver \
    ; do \
        cd /ComfyUI/custom_nodes; \
        repo_dir=$(basename "$repo" .git); \
        if [ "$repo" = "https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git" ]; then \
            git clone --recursive "$repo"; \
        else \
            git clone "$repo"; \
        fi; \
        if [ -f "/ComfyUI/custom_nodes/$repo_dir/requirements.txt" ]; then \
            pip install -r "/ComfyUI/custom_nodes/$repo_dir/requirements.txt"; \
        fi; \
        if [ -f "/ComfyUI/custom_nodes/$repo_dir/install.py" ]; then \
            python "/ComfyUI/custom_nodes/$repo_dir/install.py"; \
        fi; \
    done

# Create directory for custom files (separate from network volume)
RUN mkdir -p /src
WORKDIR /src

# Make download functions globally available
COPY src/download_hf src/download_civitai /usr/local/bin/
RUN chmod +x /usr/local/bin/download_hf /usr/local/bin/download_civitai

# Copy the rest of the source files
COPY src/ .

EXPOSE 8188 8888

CMD ["./entrypoint.sh"]