import os
from llama_cpp import Llama
import json

def run_test():
    model_path = "/Users/aiden/Projects/macinit/smart_home_projects/model_forge/training/exports/smarthome_qwen_0.5b_q4_k_m.gguf"
    
    if not os.path.exists(model_path):
        print(f"Error: Model not found at {model_path}")
        return

    print("Loading model...")
    # Initialize model
    llm = Llama(
        model_path=model_path,
        n_ctx=512,  # Context window
        n_threads=4, # Number of CPU threads
        verbose=False # Suppress llama.cpp logs to save tokens
    )

    system_prompt = "你是一个智能家居端侧Agent，负责分析用户指令或生理传感器状态，并输出多设备联动的动作数组。当前设备: [{'id': 'light_1', 'name': '主卧灯'}, {'id': 'ac_1', 'name': '客厅空调'}, {'id': 'curtain_1', 'name': '智能窗帘'}, {'id': 'ring_1', 'name': '智能戒指'}, {'id': 'bed_1', 'name': '智能床'}, {'id': 'tv_1', 'name': '智能电视'}]"

    test_cases = [
        "智能戒指检测到用户已进入深度睡眠，心率极低",
        "我要睡觉了，帮我把房间弄好",
        "智能戒指检测到用户当前HRV极低，处于高压紧绷状态",
        "我有点冷"
    ]

    print("\n--- Inference Tests ---")
    for prompt in test_cases:
        print(f"\nUser/Sensor Event: {prompt}")
        
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt}
        ]
        
        response = llm.create_chat_completion(
            messages=messages,
            max_tokens=250,
            temperature=0.1,
            top_p=0.9
        )
        
        result = response['choices'][0]['message']['content']
        print(f"AI Agent: {result}")

if __name__ == "__main__":
    run_test()