# RunPod Vanilla ComfyUI Template

## 🎯 Purpose

High-performance RunPod template for **vanilla ComfyUI** with CUDA 12.8 optimization. Clean, minimal installation ready for any workflow - from basic Stable Diffusion to advanced models like WAN 2.1/2.2.

## ⚡ Performance Features

- **CUDA 12.8**: Latest CUDA with cutting-edge optimizations and performance
- **UV Package Manager**: 10-100x faster dependency installation
- **Dynamic VRAM Optimization**: Automatically adjusts settings based on GPU memory
- **FP16 Precision**: 2x memory savings with maintained quality
- **Vanilla Installation**: Clean setup without bloat, install only what you need

## 🚀 Quick Start

### **Production Deployment (RunPod)**

```bash
# Option 1: Use pre-built Docker image from Docker Hub
# Replace 'your-username' with your actual Docker Hub username
docker pull your-username/comfyui-runpod:latest

# Option 2: Build locally and upload template to RunPod
# RunPod handles container orchestration, GPU access, and networking
```

**RunPod Configuration:**
- **GPU**: RTX 4090, A100, H100 (recommended for WAN models)
- **VRAM**: Minimum 12GB, 24GB+ recommended for video generation
- **Storage**: 50GB+ for models and outputs
- **Ports**: 8188 (ComfyUI), 8888 (Jupyter)

### **Local M1 Mac Testing**

```bash
# Build and run M1 Mac version (CPU-only)
docker-compose -f docker-compose.m1.yml up --build -d

# Access locally
# ComfyUI: http://localhost:8188
# Jupyter: http://localhost:8888

# Stop testing
docker-compose -f docker-compose.m1.yml down
```

### **API Token Setup (Optional but Recommended)**

Configure these environment variables in your RunPod template for enhanced model access:

```bash
# Hugging Face Token (for gated models and faster downloads)
HF_TOKEN=hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# CivitAI Token (for CivitAI model downloads without rate limits)
CIVITAI_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**How to get tokens:**
- **Hugging Face**: Visit [https://huggingface.co/settings/tokens](https://huggingface.co/settings/tokens)
- **CivitAI**: Visit [https://civitai.com/user/account](https://civitai.com/user/account) → API Keys


**M1 Mac Files:**
- `Dockerfile.m1` - M1 Mac optimized Docker image (multi-stage build)
- `docker-compose.m1.yml` - M1 Mac testing configuration
- `run-comfy-wan/start.m1.sh` - M1 Mac startup script

## 📁 Project Structure

```
├── run-comfy-wan/                # Runtime scripts
│   ├── start.sh                  # Production startup script
│   ├── start.m1.sh               # M1 Mac startup script
│   └── start_jupyter.sh          # Jupyter server startup script
├── docker-compose.m1.yml         # M1 Mac local testing configuration
├── Dockerfile                    # Main production Docker image (multi-stage)
├── Dockerfile.m1                 # M1 Mac testing Docker image (multi-stage)
├── requirements.txt              # Python dependencies for production
├── requirements.m1.txt           # Python dependencies for M1 Mac testing
├── .env.example                  # Environment variables template
├── .gitignore                    # Git ignore rules for runtime files
├── local_volumes/                # Local development volumes (git-ignored)
│   ├── models/                   # Model storage directory
│   ├── input/                    # Input files directory
│   ├── output/                   # Generated outputs directory
│   ├── cache/                    # Model cache directory
│   └── logs/                     # Application logs
└── README.md                     # This documentation
```

## 📦 Dependency Management

This project uses traditional **`requirements.txt`** files for reliable dependency management:

### **Architecture-Specific Dependencies:**
```bash
# Production (CUDA 12.8 + GPU acceleration)
pip install -r requirements.txt

# M1 Mac (CPU-only for Apple Silicon)  
pip install -r requirements.m1.txt
```

### **Key Benefits:**
- **🎯 Architecture-aware**: Separate files for CUDA vs CPU PyTorch
- **🔒 Reliable**: Battle-tested pip dependency resolution
- **🧹 Simple**: Easy to understand and maintain
- **🔄 Compatible**: Works with all Python tooling
- **📋 Clear**: Explicit dependency specifications

## 📂 Local Development Volumes

The `local_volumes/` directory provides persistent storage for local development and testing:

```bash
local_volumes/
├── models/     # Store your ComfyUI models (.ckpt, .safetensors files)
├── input/      # Input images/videos for processing
├── output/     # Generated outputs from ComfyUI
├── cache/      # Hugging Face model cache (speeds up subsequent runs)
└── logs/       # Application logs (comfyui.log, jupyter.log)
```

**Important Notes:**
- 📁 **Git Ignored**: This directory is excluded from git (contains large model files)
- 🔄 **Persistent**: Data persists between container restarts
- 📦 **Models**: Download models directly to `local_volumes/models/`
- 🚀 **Performance**: Cache directory speeds up model loading

## 🔄 CI/CD & Automated Builds

This project includes GitHub Actions workflows for automated Docker image building and deployment:

### **🐳 Docker Hub Integration**

**Automated Builds:**
- ✅ **Triggers**: Push to main branch, releases, manual dispatch
- ✅ **Multi-tagging**: `latest`, `cuda-12.8`, version tags, commit SHA
- ✅ **Caching**: GitHub Actions cache for faster subsequent builds
- ✅ **Security**: Trivy vulnerability scanning
- ✅ **Multi-arch**: AMD64 (production) + ARM64 (M1 Mac testing)

**Available Images:**
```bash
# Latest production image with CUDA 12.8
docker pull your-username/comfyui-runpod:latest

# Specific CUDA version
docker pull your-username/comfyui-runpod:cuda-12.8

# M1 Mac CPU-only version
docker pull your-username/comfyui-runpod:m1-latest

# Specific version (from git tags)
docker pull your-username/comfyui-runpod:v1.0.0
```

### **⚙️ Setup Instructions**

**1. Fork this repository**

**2. Set up Docker Hub secrets in your GitHub repository:**
- Go to `Settings` → `Secrets and variables` → `Actions`
- Add these secrets:
  - `DOCKERHUB_USERNAME`: Your Docker Hub username
  - `DOCKERHUB_TOKEN`: Your Docker Hub access token ([create here](https://hub.docker.com/settings/security))

**3. Choose your workflow:**
- **Full workflow**: Use `.github/workflows/docker-build.yml` (comprehensive)
- **Simple workflow**: Use `.github/workflows/docker-simple.yml` (minimal)
- Delete the one you don't want

**4. Push to main branch or create a release:**
```bash
git add .
git commit -m "feat: setup automated Docker builds"
git push origin main
```

**5. Check GitHub Actions tab for build progress**

### **🎯 Workflow Features**

**Full Workflow (`docker-build.yml`):**
- ✅ Semantic versioning from git tags
- ✅ Pull request builds (without pushing)
- ✅ Security scanning with Trivy
- ✅ M1 Mac image builds
- ✅ Comprehensive metadata and labels
- ✅ Build notifications

**Simple Workflow (`docker-simple.yml`):**
- ✅ Basic build and push on main branch
- ✅ Three tags: `latest`, `cuda-12.8`, commit SHA
- ✅ GitHub Actions caching
- ✅ Minimal configuration

## 🔧 Technical Specifications

### Base Configuration

- **Base Image**: `nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04` (multi-stage build)
- **Python**: 3.11 (10-25% performance improvement over 3.10)
- **PyTorch**: 2.4.0+ with CUDA 12.8 support
- **ComfyUI**: Latest stable (managed via official CLI v1.5.1)
- **Package Manager**: UV (primary) + pip (fallback)
- **Architecture**: Multi-stage Docker build for optimized image size

### GPU Optimization Strategy

| VRAM | Optimization Level | Settings |
|------|-------------------|----------|
| <8GB | Aggressive | `--lowvram --cpu-vae` |
| 8-12GB | Standard | `--lowvram` |
| 12-24GB | Optimal | Default settings |
| 24GB+ | Maximum | High-performance mode |

### Vanilla Installation

- **No pre-installed custom nodes** - Clean, minimal setup
- **Install nodes as needed** - Use ComfyUI's built-in node installer
- **Maximum compatibility** - No conflicts from pre-installed extensions
- **Faster startup** - Minimal overhead from unnecessary components

### ComfyUI Version Management

- **Latest Stable**: Automatically installs current stable release
- **Official CLI**: Uses `comfy-cli==1.5.1` for reliable installation
- **Reproducible Builds**: CLI ensures consistent installations
- **Easy Updates**: Rebuild container to get latest stable version

## 🎨 Installing Custom Nodes & Models

### Adding Custom Nodes

1. Access ComfyUI web interface
2. Use the built-in node installer or manually install via git
3. For popular nodes, use ComfyUI Manager (install it first if needed)
4. Restart ComfyUI when prompted after installing nodes

### Model Download Locations

```bash
# Standard ComfyUI Model Directories
/workspace/ComfyUI/models/checkpoints/    # Main model files (SDXL, SD1.5, etc.)
/workspace/ComfyUI/models/vae/            # VAE models for better image quality
/workspace/ComfyUI/models/loras/          # LoRA files for style/character training
/workspace/ComfyUI/models/controlnet/     # ControlNet models for guided generation
/workspace/ComfyUI/models/diffusers/      # Hugging Face format models

# Quick access symlinks
/workspace/models/     -> /workspace/ComfyUI/models/
/workspace/input/      -> /workspace/ComfyUI/input/
/workspace/output/     -> /workspace/ComfyUI/output/
```

## 🛠️ Customization

### Environment Variables

```bash
# CUDA Configuration
CUDA_VISIBLE_DEVICES=0                    # Use first GPU only
PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:128  # Memory fragmentation control

# Model Caching
TRANSFORMERS_CACHE=/workspace/cache/transformers
HF_HOME=/workspace/cache/huggingface
```

### Startup Arguments

Modify `start.sh` to customize ComfyUI behavior:

```bash
# Base configuration
COMFY_ARGS="--listen 0.0.0.0 --port 8188"

# Performance options
COMFY_ARGS="$COMFY_ARGS --force-fp16"        # Half precision
COMFY_ARGS="$COMFY_ARGS --preview-method auto"  # Real-time previews

# Memory optimization (auto-detected)
COMFY_ARGS="$COMFY_ARGS --lowvram"           # For <12GB VRAM
```

## 📊 Performance Benchmarks

### Expected Performance (RTX 4090)

- **1024x1024 Image**: 3-5 seconds
- **2048x2048 Image**: 8-12 seconds  
- **Video (16 frames)**: 30-60 seconds
- **Batch Processing**: 2-3x faster with optimizations

### Memory Usage

- **Base ComfyUI**: ~2GB VRAM
- **WAN 2.1 Model**: ~6-8GB VRAM
- **WAN 2.2 Model**: ~8-10GB VRAM
- **Video Generation**: +2-4GB VRAM

## 🔍 Troubleshooting

### Common Issues

#### GPU Not Detected

```bash
# Check CUDA availability
python -c "import torch; print(torch.cuda.is_available())"

# Verify NVIDIA drivers
nvidia-smi
```

#### Out of Memory Errors

1. Reduce batch size in workflows
2. Enable `--lowvram` mode
3. Use `--cpu-vae` for extreme cases
4. Close other GPU applications

#### Slow Performance

1. Verify CUDA 12.4 installation
2. Check GPU utilization with `nvidia-smi`
3. Ensure FP16 mode is enabled
4. Monitor system resources

### Log Analysis

```bash
# Real-time logs
tail -f /workspace/logs/comfyui.log

# Error analysis
grep -i error /workspace/logs/comfyui.log

# Performance monitoring
grep -i "memory\|cuda\|gpu" /workspace/logs/comfyui.log
```

## 🔄 Updates and Maintenance

### Updating ComfyUI

```bash
# Update core ComfyUI
cd /workspace/ComfyUI
git pull

# Update custom nodes via ComfyUI Manager
# Use the web interface: Manager > Update All
```

### Adding New Custom Nodes

1. Use ComfyUI Manager (recommended)
2. Manual installation:

```bash
cd /workspace/ComfyUI/custom_nodes
git clone <node-repository>
cd <node-directory>
pip install -r requirements.txt
```

## 🤝 Contributing

### Code Style

- Follow the commenting rules in `.windsurf/rules.md`
- Explain what code does, how it works, and why it's necessary
- Use clear, descriptive variable names
- Add performance impact comments for optimizations

### Testing

- Test on multiple GPU tiers (RTX 4090, A100, H100)
- Verify VRAM optimization across different memory sizes
- Validate WAN model compatibility

## 📄 License

This template is provided as-is for educational and commercial use. Please respect the licenses of included software:

- ComfyUI: GPL-3.0 License
- PyTorch: BSD License
- Custom nodes: Various licenses (check individual repositories)

## 🆘 Support

### Resources

- [ComfyUI Documentation](https://github.com/comfyanonymous/ComfyUI)
- [RunPod Documentation](https://docs.runpod.io/)
- [WAN Model Papers and Resources](https://huggingface.co/warp-ai)

### Community

- ComfyUI Discord Server
- RunPod Community Forums
- GitHub Issues for template-specific problems

---

## 🎉 Ready to Create

Your RunPod ComfyUI template is now ready for WAN 2.1/2.2 model integration. The system automatically optimizes for your GPU configuration and provides professional-grade tools for image and video generation.

**Next Steps:**

1. Deploy on RunPod
2. Install WAN-specific nodes via ComfyUI Manager
3. Download your preferred WAN models
4. Start creating amazing content!

---

*Built with ❤️ for the AI art community*
