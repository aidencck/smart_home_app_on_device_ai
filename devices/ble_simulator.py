import time
import json
import logging
import asyncio

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger("BLE_Simulator")

# Simulated Luma AI devices
DEVICES = [
    {
        "name": "Luma Smart Light",
        "mac_address": "AA:BB:CC:DD:EE:01",
        "service_uuid": "0000ffe0-0000-1000-8000-00805f9b34fb",
        "characteristics": {
            "power": True,
            "brightness": 80,
            "color": "#FFFFFF"
        }
    },
    {
        "name": "Luma Smart Bed",
        "mac_address": "AA:BB:CC:DD:EE:02",
        "service_uuid": "0000ffe1-0000-1000-8000-00805f9b34fb",
        "characteristics": {
            "occupancy": False,
            "temperature": 24.5,
            "head_elevation": 15
        }
    },
    {
        "name": "Luma Smart Ring",
        "mac_address": "AA:BB:CC:DD:EE:03",
        "service_uuid": "0000ffe2-0000-1000-8000-00805f9b34fb",
        "characteristics": {
            "heart_rate": 72,
            "sleep_stage": "light",
            "battery": 85
        }
    }
]

async def simulate_broadcast(device):
    """Simulates the BLE broadcasting of a device."""
    while True:
        payload = json.dumps(device["characteristics"])
        logger.info(f"Broadcasting from {device['name']} ({device['mac_address']}) - UUID: {device['service_uuid']} - Data: {payload}")
        # Simulate broadcast interval
        await asyncio.sleep(2)

async def main():
    logger.info("Starting BLE simulation for Luma AI smart devices...")
    tasks = []
    for device in DEVICES:
        tasks.append(asyncio.create_task(simulate_broadcast(device)))
    
    await asyncio.gather(*tasks)

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("BLE simulation stopped.")
