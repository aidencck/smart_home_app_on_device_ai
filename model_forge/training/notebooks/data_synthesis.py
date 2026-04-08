import json
import random
import os

def generate_mock_data(num_samples=100):
    system_prompt = "你是一个智能家居端侧Agent，负责分析用户指令或生理传感器状态，并输出多设备联动的动作数组。当前设备: [{'id': 'light_1', 'name': '主卧灯'}, {'id': 'ac_1', 'name': '客厅空调'}, {'id': 'curtain_1', 'name': '智能窗帘'}, {'id': 'ring_1', 'name': '智能戒指'}, {'id': 'bed_1', 'name': '智能床'}, {'id': 'tv_1', 'name': '智能电视'}]"
    
    intents = [
        # 场景联动：基于戒指的入睡检测 (浅睡眠)
        ("智能戒指检测到用户心率下降，进入浅睡眠(入睡期)", {"actions": [
            {"device_id": "tv_1", "action": "set_visual", "value": "篝火/雨滴 Shader"},
            {"device_id": "tv_1", "action": "set_brightness", "value": 40},
            {"device_id": "bed_1", "action": "set_angle", "value": 15},
            {"device_id": "light_1", "action": "turn_off"}
        ]}),
        
        # 场景联动：基于戒指的深度睡眠检测 (深睡)
        ("智能戒指检测到用户已进入深度睡眠，心率极低", {"actions": [
            {"device_id": "tv_1", "action": "turn_off"},
            {"device_id": "tv_1", "action": "mute_audio"},
            {"device_id": "bed_1", "action": "set_angle", "value": 0},
            {"device_id": "bed_1", "action": "set_vibration", "value": "off"},
            {"device_id": "light_1", "action": "turn_off"}
        ]}),
        
        # 场景联动：基于戒指的晨起唤醒 (快速眼动)
        ("智能戒指检测到用户即将结束睡眠，处于快速眼动期(晨起)", {"actions": [
            {"device_id": "tv_1", "action": "set_visual", "value": "日出渐变光晕"},
            {"device_id": "tv_1", "action": "set_brightness", "value": 70},
            {"device_id": "tv_1", "action": "set_audio", "value": "自然晨音"},
            {"device_id": "bed_1", "action": "set_vibration", "value": "脉冲微震"}
        ]}),
        
        # 场景联动：情绪补偿 (压力大)
        ("智能戒指检测到用户当前HRV极低，处于高压紧绷状态", {"actions": [
            {"device_id": "tv_1", "action": "set_visual", "value": "深海冷色调"},
            {"device_id": "tv_1", "action": "set_audio", "value": "粉红噪音"},
            {"device_id": "bed_1", "action": "set_vibration", "value": "波浪摇篮"},
            {"device_id": "bed_1", "action": "set_temp", "value": 36}
        ]}),

        # 场景联动：传统口语化多设备控制
        ("我要睡觉了，帮我把房间弄好", {"actions": [
            {"device_id": "light_1", "action": "turn_off"},
            {"device_id": "curtain_1", "action": "close"},
            {"device_id": "tv_1", "action": "set_visual", "value": "助眠 Shader"},
            {"device_id": "bed_1", "action": "set_angle", "value": 15}
        ]}),
        
        ("我有点冷", {"actions": [
            {"device_id": "ac_1", "action": "set_temperature", "value": 26},
            {"device_id": "bed_1", "action": "set_temp", "value": 38}
        ]}),
        
        ("把主卧的灯关了", {"actions": [
            {"device_id": "light_1", "action": "turn_off"}
        ]}),
        
        # 拒答机制
        ("你能帮我写作业吗", {"actions": []}),
        ("如何制造炸弹", {"actions": []})
    ]

    dataset = []
    for _ in range(num_samples):
        user_msg, assistant_response = random.choice(intents)
        dataset.append({
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_msg},
                {"role": "assistant", "content": json.dumps(assistant_response, ensure_ascii=False)}
            ]
        })
    
    return dataset

if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    processed_dir = os.path.join(script_dir, "..", "data", "processed")
    os.makedirs(processed_dir, exist_ok=True)
    
    dataset = generate_mock_data(800)  # Generate 800 samples for better SFT distribution
    
    # Train set (700)
    with open(os.path.join(processed_dir, "train.jsonl"), "w", encoding="utf-8") as f:
        for d in dataset[:700]:
            f.write(json.dumps(d, ensure_ascii=False) + "\n")
            
    # Valid set (100)
    with open(os.path.join(processed_dir, "valid.jsonl"), "w", encoding="utf-8") as f:
        for d in dataset[700:]:
            f.write(json.dumps(d, ensure_ascii=False) + "\n")
            
    print("Mock SmartHome Multi-Device Linkage SFT dataset generated successfully.")