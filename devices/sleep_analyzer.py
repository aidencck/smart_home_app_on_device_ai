import time
import random
import requests
import logging
from collections import deque
from enum import Enum

# 配置日志输出
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

class SleepStage(Enum):
    AWAKE = "AWAKE"
    LIGHT_SLEEP = "LIGHT_SLEEP"
    DEEP_SLEEP = "DEEP_SLEEP"

class SleepAnalyzer:
    def __init__(self, device_id="ring_001", window_size=5, token=""):
        self.device_id = device_id
        self.trigger_url = "http://127.0.0.1:8000/api/v1/automations/trigger"
        self.window_size = window_size
        self.data_window = deque(maxlen=window_size)
        self.current_stage = SleepStage.AWAKE
        self.token = token
        
    def simulate_data(self):
        """模拟智能戒指采集的生理和运动数据"""
        # 为了让状态更平滑过渡，我们在一定范围内波动生成数据
        hr = random.uniform(45, 85)          # 心率 (bpm)
        hrv = random.uniform(20, 100)        # 心率变异性 (ms)
        movement = random.uniform(0, 8)      # 体动幅度 (0-10)
        return {"hr": hr, "hrv": hrv, "movement": movement}

    def analyze_window(self):
        """滑动窗口算法计算睡眠分期"""
        if len(self.data_window) < self.window_size:
            return self.current_stage
            
        avg_hr = sum(d["hr"] for d in self.data_window) / self.window_size
        avg_hrv = sum(d["hrv"] for d in self.data_window) / self.window_size
        avg_movement = sum(d["movement"] for d in self.data_window) / self.window_size
        
        # 简单的睡眠分期逻辑规则
        if avg_movement > 4 or avg_hr > 70:
            return SleepStage.AWAKE
        elif avg_movement < 1.5 and avg_hr < 55 and avg_hrv > 60:
            return SleepStage.DEEP_SLEEP
        else:
            return SleepStage.LIGHT_SLEEP

    def trigger_automation(self, new_stage):
        """状态改变时触发自动化 webhook，使用防阻塞超时机制"""
        payload = {
            "event_type": new_stage.name,
            "payload": {
                "device_id": self.device_id
            }
        }
        
        headers = {}
        if self.token:
            headers["Authorization"] = f"Bearer {self.token}"
            
        try:
            logging.info(f"正在向服务端推送状态更新: {payload}")
            # 设置短超时时间 (3秒) 避免阻塞，确保数据采集不受网络影响
            response = requests.post(self.trigger_url, json=payload, headers=headers, timeout=3.0)
            response.raise_for_status()
            logging.info(f"推送成功，服务端响应状态码: {response.status_code}")
            
        except requests.exceptions.Timeout:
            logging.warning("HTTP 请求超时，跳过本次触发。系统将继续运行...")
        except requests.exceptions.ConnectionError:
            logging.error("连接服务端失败 (ConnectionError)，请检查服务是否启动。")
        except requests.exceptions.HTTPError as e:
            logging.error(f"HTTP 请求返回错误状态码: {e}")
        except requests.exceptions.RequestException as e:
            logging.error(f"HTTP 请求遇到异常: {e}")

    def run(self):
        """主运行循环"""
        logging.info(f"启动睡眠分析器 (设备: {self.device_id})")
        logging.info(f"窗口大小: {self.window_size} 次采样")
        
        try:
            while True:
                # 1. 采集（模拟）数据
                data = self.simulate_data()
                self.data_window.append(data)
                
                # 2. 分析当前窗口数据
                new_stage = self.analyze_window()
                
                # 3. 状态判断及触发
                if new_stage != self.current_stage and len(self.data_window) == self.window_size:
                    logging.info(f"检测到睡眠分期改变: {self.current_stage.name} -> {new_stage.name}")
                    self.trigger_automation(new_stage)
                    self.current_stage = new_stage
                    
                # 模拟每 2 秒采集一次数据
                time.sleep(2)
                
        except KeyboardInterrupt:
            logging.info("收到中断信号，睡眠分析器已停止运行。")

if __name__ == "__main__":
    analyzer = SleepAnalyzer()
    analyzer.run()
