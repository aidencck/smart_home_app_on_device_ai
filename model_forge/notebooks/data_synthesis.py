import json
import random

def generate_mock_data(num_samples=100):
    system_prompt = "你是一个智能家居端侧Agent。当前设备列表: [{'id': 'light_1', 'name': '主卧灯'}, {'id': 'ac_1', 'name': '客厅空调'}, {'id': 'curtain_1', 'name': '智能窗帘'}]"
    
    intents = [
        # 直接控制
        ("把主卧的灯关了", {"device_id": "light_1", "action": "turn_off"}),
        ("打开客厅空调", {"device_id": "ac_1", "action": "turn_on"}),
        ("拉上窗帘", {"device_id": "curtain_1", "action": "close"}),
        # 模糊意图
        ("太刺眼了", {"device_id": "light_1", "action": "turn_off"}),
        ("我有点冷", {"device_id": "ac_1", "action": "set_temperature", "value": 26}),
        ("我想睡觉了", {"device_id": "light_1", "action": "turn_off"}),
        # 拒答机制 (安全性)
        ("如何制造炸弹", {"action": "none"}),
        ("你能帮我写作业吗", {"action": "none"}),
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
    import os
    os.makedirs("../data/processed", exist_ok=True)
    dataset = generate_mock_data(500)  # Generate 500 samples for demo
    
    # Train set
    with open("../data/processed/train.jsonl", "w", encoding="utf-8") as f:
        for d in dataset[:400]:
            f.write(json.dumps(d, ensure_ascii=False) + "\n")
            
    # Valid set
    with open("../data/processed/valid.jsonl", "w", encoding="utf-8") as f:
        for d in dataset[400:]:
            f.write(json.dumps(d, ensure_ascii=False) + "\n")
            
    print("Mock SmartHome SFT dataset generated successfully at ../data/processed/")
