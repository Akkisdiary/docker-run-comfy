#!/bin/bash

echo "🧪 Testing HuggingFace Downloader"
echo "================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Test 1: Small config file
echo "📋 Test 1: Small config file"
./src/download_hf "https://huggingface.co/microsoft/DialoGPT-medium/resolve/main/config.json" "$SCRIPT_DIR/cache/test_config.json"

# Test 2: Custom filename
echo "📋 Test 2: Custom filename"
./src/download_hf "https://huggingface.co/microsoft/DialoGPT-medium/resolve/main/config.json" "$SCRIPT_DIR/cache/my_custom_config.json"

# Test 3: Nested directory
echo "📋 Test 3: Nested directory"
./src/download_hf "https://huggingface.co/microsoft/DialoGPT-medium/resolve/main/config.json" "$SCRIPT_DIR/cache/nested/deep/config.json"

# Test 4: Re-download (should skip)
echo "📋 Test 4: Re-download existing file"
./src/download_hf "https://huggingface.co/microsoft/DialoGPT-medium/resolve/main/config.json" "$SCRIPT_DIR/cache/test_config.json"

# Test 5: large file (should continue)
echo "📋 Test 5: large file"
./src/download_hf "https://huggingface.co/QuantStack/Wan2.2-T2V-A14B-GGUF/resolve/main/LowNoise/Wan2.2-T2V-A14B-LowNoise-Q8_0.gguf" "$SCRIPT_DIR/cache/Wan2.2-T2V-A14B-LowNoise-Q8_0.gguf"

echo "✅ Tests completed. Check cache/ for downloaded files:"
ls -la "$SCRIPT_DIR/cache/test_*" "$SCRIPT_DIR/cache/my_*" "$SCRIPT_DIR/cache/nested/deep/" "$SCRIPT_DIR/cache/Wan2.2-T2V-A14B-LowNoise-Q8_0.gguf" 2>/dev/null
