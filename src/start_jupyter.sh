#!/bin/bash

set -e

echo "📓 Starting JupyterLab..."

NETWORK_VOLUME="${NETWORK_VOLUME:-/workspace}"

jupyter-lab --ip=0.0.0.0 --allow-root --no-browser \
    --ServerApp.token='' --ServerApp.password='' \
    --ServerApp.allow_origin='*' --ServerApp.allow_credentials=True \
    --notebook-dir="/" &

export JUPYTER_PID=$!
echo "✅ JupyterLab started (PID: $JUPYTER_PID)"

sleep 3
if kill -0 "$JUPYTER_PID" 2>/dev/null; then
    echo "🚀 JupyterLab is starting up!"
    echo "📓 JupyterLab URL: http://localhost:8888"
    echo "⏳ JupyterLab should be ready in a few seconds..."
else
    echo "❌ JupyterLab failed to start"
    exit 1
fi

echo "✅ JupyterLab startup completed"
