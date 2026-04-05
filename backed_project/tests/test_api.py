import pytest
import time
from httpx import AsyncClient, ASGITransport
from app.core.config import settings
from main import app
import app.db.redis as redis_module
import asyncio

pytestmark = pytest.mark.asyncio

async def test_device_shadow_vector_clock():
    await redis_module.init_redis()
    device_id = "test_device_vector_clock"
    
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        # 1. Update shadow with ts = 100
        payload_1 = {
            "updates": [
                {
                    "device_id": device_id,
                    "state": '{"power": "on"}',
                    "last_update_ts": 100,
                    "is_high_risk": False
                }
            ]
        }
        
        response = await ac.post(f"{settings.API_V1_STR}/devices/shadow/batch", json=payload_1)
        assert response.status_code == 200
        data = response.json()
        assert data["code"] == 200
        
        # 2. Try to update shadow with ts = 90 (Stale Data)
        payload_2 = {
            "updates": [
                {
                    "device_id": device_id,
                    "state": '{"power": "off"}',
                    "last_update_ts": 90,
                    "is_high_risk": False
                }
            ]
        }
        response2 = await ac.post(f"{settings.API_V1_STR}/devices/shadow/batch", json=payload_2)
        assert response2.status_code == 200 # endpoint returns 200 but internally rejects
        
        # Verify redis state directly
        state = await redis_module.redis_client.hget(f"device:shadow:{device_id}", "state")
        assert state == '{"power": "on"}'

async def test_ai_gateway_anti_replay_and_acl():
    await redis_module.init_redis()
    device_id = "test_device_ai"
    command_id = f"cmd_{int(time.time())}"
    
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        # 1. Setup device shadow with ts = 200
        payload_setup = {
            "updates": [
                {
                    "device_id": device_id,
                    "state": '{"power": "on"}',
                    "last_update_ts": 200,
                    "is_high_risk": False
                }
            ]
        }
        await ac.post(f"{settings.API_V1_STR}/devices/shadow/batch", json=payload_setup)
        
        # 2. Send AI command with stale context (ts = 150)
        ai_payload_stale = {
            "command_id": command_id,
            "query": "Turn on the light",
            "context": [
                {
                    "device_id": device_id,
                    "state": '{"power": "on"}',
                    "last_update_ts": 150
                }
            ],
            "hardware_level": "home_1"
        }
        
        response_stale = await ac.post(
            f"{settings.API_V1_STR}/ai/chat", 
            json=ai_payload_stale,
            headers={"Authorization": "Bearer valid_token"}
        )
        
        assert response_stale.status_code == 200
        assert response_stale.json()["code"] == 3003
        assert "状态版本已过期" in response_stale.json()["message"]
        
        # 3. Test anti-replay: manually lock the command_id in Redis
        await redis_module.redis_client.set(f"cmd_exec:home_1:{command_id}", "processing", ex=10)
        
        ai_payload_replay = {
            "command_id": command_id,
            "query": "Turn on the light",
            "context": [
                {
                    "device_id": device_id,
                    "state": '{"power": "on"}',
                    "last_update_ts": 200
                }
            ],
            "hardware_level": "home_1"
        }
        
        response_replay = await ac.post(
            f"{settings.API_V1_STR}/ai/chat", 
            json=ai_payload_replay,
            headers={"Authorization": "Bearer valid_token"}
        )
        
        assert response_replay.status_code == 400
        assert "请勿重复提交" in response_replay.json()["message"]
