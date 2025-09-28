#!/bin/bash

# Services Monitor Script
# Monitors running services and keeps container alive

set +e  # Don't exit on errors

echo "👀 Starting service monitoring..."

# Use environment variables
LOG_FILE="${LOG_FILE:-/comfyui_container.log}"

# Cleanup function
cleanup() {
    echo "🛑 Shutting down services..."
    if [ -n "$COMFYUI_PID" ] && kill -0 "$COMFYUI_PID" 2>/dev/null; then
        kill -TERM "$COMFYUI_PID"
        wait "$COMFYUI_PID" 2>/dev/null || true
    fi
    if [ -n "$JUPYTER_PID" ] && kill -0 "$JUPYTER_PID" 2>/dev/null; then
        kill -TERM "$JUPYTER_PID"
        wait "$JUPYTER_PID" 2>/dev/null || true
    fi
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Monitor processes and keep container alive
echo "✅ Setup complete. Monitoring services..."
while true; do
    # Check if ComfyUI is still running
    if ! kill -0 "$COMFYUI_PID" 2>/dev/null; then
        echo "❌ ComfyUI process died unexpectedly"
        echo "📋 Last 20 lines of log:"
        tail -n 20 "$LOG_FILE" 2>/dev/null || echo "No log file found"
        exit 1
    fi
    
    # Check if JupyterLab is still running
    if ! kill -0 "$JUPYTER_PID" 2>/dev/null; then
        echo "⚠️  JupyterLab process died, restarting..."
        jupyter-lab --ip=0.0.0.0 --allow-root --no-browser \
            --ServerApp.token='' --ServerApp.password='' \
            --ServerApp.allow_origin='*' --ServerApp.allow_credentials=True \
            --notebook-dir="/" &
        JUPYTER_PID=$!
        echo "✅ JupyterLab restarted (PID: $JUPYTER_PID)"
    fi
    
    # Sleep for 10 seconds before next check
    sleep 10
done
