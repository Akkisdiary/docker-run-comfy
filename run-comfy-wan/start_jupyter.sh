#!/bin/bash

# =============================================================================
# Vanilla Jupyter Server Startup Script
# =============================================================================
# Purpose: Start a basic Jupyter notebook server for development
# Features: Simple configuration, exposed on port 8888
# =============================================================================

# Exit on any error to prevent running with broken configuration
set -e

echo "📓 Starting vanilla Jupyter notebook server..."

# Create Jupyter configuration directory
mkdir -p /workspace/.jupyter

# Create minimal Jupyter configuration file
cat > /workspace/.jupyter/jupyter_notebook_config.py << 'EOF'
# Minimal Jupyter Notebook Configuration
# Purpose: Basic Jupyter server configuration for Docker container access

# Network Configuration:
# Allow connections from any IP address (required for Docker containers)
c.NotebookApp.ip = '0.0.0.0'

# Port Configuration:
# Use standard Jupyter port 8888
c.NotebookApp.port = 8888

# Security Configuration:
# Disable token authentication for development container
c.NotebookApp.token = ''
c.NotebookApp.password = ''

# Allow root user (required in Docker containers)
c.NotebookApp.allow_root = True

# Browser Configuration:
# Don't try to open browser (not available in container)
c.NotebookApp.open_browser = False

# Working Directory:
# Set notebook root to workspace for easy access to all files
c.NotebookApp.notebook_dir = '/workspace'

# File Access:
# Allow access to hidden files for configuration editing
c.ContentsManager.allow_hidden = True
EOF

echo "✅ Jupyter configuration created"

# Start Jupyter server in background
echo "🚀 Starting Jupyter server..."
jupyter lab --ip=0.0.0.0 --port=8888 --ServerApp.token='' --ServerApp.password='' --no-browser --allow-root --notebook-dir=/workspace > /workspace/logs/jupyter.log 2>&1 &
JUPYTER_PID=$!

# Wait for startup
sleep 3

# Check if Jupyter started successfully
if kill -0 $JUPYTER_PID 2>/dev/null; then
    echo "✅ Jupyter server started successfully!"
    echo "📋 Access Information:"
    echo "   🌐 Jupyter URL: http://localhost:8888"
    echo "   📁 Working Directory: /workspace"
    echo "   📝 Logs: /workspace/logs/jupyter.log"
else
    echo "❌ Failed to start Jupyter server"
    echo "📄 Error logs:"
    cat /workspace/logs/jupyter.log
    exit 1
fi
