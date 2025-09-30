#!/bin/bash

echo "🧪 Testing CivitAI Downloader"
echo "================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Test 1: Small config file
echo "📋 Test 1: Small config file"
./src/download_civitai "2066914" "$SCRIPT_DIR/cache/"

# # Test 2: Custom filename
# echo "📋 Test 2: Custom filename"
# ./src/download_civitai "126666" "$SCRIPT_DIR/cache/my_custom_config.json"

# # Test 3: Nested directory
# echo "📋 Test 3: Nested directory"
# ./src/download_civitai "126666" "$SCRIPT_DIR/cache/nested/deep/config.json"

# # Test 4: Re-download (should skip)
# echo "📋 Test 4: Re-download existing file"
# ./src/download_civitai "https://huggingface.co/microsoft/DialoGPT-medium/resolve/main/config.json" "$SCRIPT_DIR/cache/test_config.json"


echo "✅ Tests completed. Check cache/ for downloaded files:"
ls -la "$SCRIPT_DIR/cache/test_*" "$SCRIPT_DIR/cache/my_*" "$SCRIPT_DIR/cache/nested/deep/" "$SCRIPT_DIR/cache/Wan2.2-T2V-A14B-LowNoise-Q8_0.gguf" 2>/dev/null
