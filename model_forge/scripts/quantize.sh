#!/bin/bash
set -e

echo "🚀 Starting Fusion & Quantization Pipeline..."

# 1. Fuse LoRA with Base Model using MLX
echo "1️⃣ Fusing LoRA weights with Qwen2.5-0.5B..."
../venv/bin/python -m mlx_lm.fuse \
    --model Qwen/Qwen2.5-0.5B-Instruct \
    --adapter-path ../exports/adapters \
    --save-path ../exports/fused_model

echo "2️⃣ Preparing llama.cpp..."
if [ ! -d "llama.cpp" ]; then
    echo "Cloning llama.cpp for conversion and quantization..."
    git clone https://github.com/ggerganov/llama.cpp.git
    cd llama.cpp
    cmake -B build
    cmake --build build --config Release -j 10
    cd ..
fi

echo "3️⃣ Converting Fused Model to GGUF (FP16)..."
# We need to ensure we have the necessary dependencies for the conversion script
../venv/bin/python llama.cpp/convert_hf_to_gguf.py ../exports/fused_model \
    --outfile ../exports/smarthome_qwen_0.5b_fp16.gguf \
    --outtype f16

echo "4️⃣ Quantizing to Q4_K_M..."

./llama.cpp/build/bin/llama-quantize ../exports/smarthome_qwen_0.5b_fp16.gguf ../exports/smarthome_qwen_0.5b_q4_k_m.gguf Q4_K_M

echo "✅ All done! The final model is at exports/smarthome_qwen_0.5b_q4_k_m.gguf"
