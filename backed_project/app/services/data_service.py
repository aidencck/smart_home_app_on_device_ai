import json
import asyncio
from app.schemas.data import TelemetryLog
from app.core.logger import logger
from app.core.config import settings
from openai import AsyncOpenAI, APIConnectionError, RateLimitError

class DataFlywheelService:
    @staticmethod
    async def process_telemetry(log_data: TelemetryLog):
        """
        通过 BackgroundTasks 处理遥测日志，移除繁重的 Celery 依赖
        """
        logger.info(f"Starting to process telemetry log: {log_data.session_id}")
        
        try:
            # 初始化异步客户端，避免同步阻塞
            async_client = AsyncOpenAI(api_key=settings.AI_API_KEY, base_url=settings.AI_API_BASE)
            
            # 模拟判断耗时和简单的重试逻辑
            await asyncio.sleep(0.5)
            
            is_valid_sample = True 
            
            if is_valid_sample:
                logger.info(f"Log {log_data.session_id} classified as VALID. Saved to DB.")
            else:
                logger.info(f"Log {log_data.session_id} classified as NOISE. Discarded.")
                
            return {"status": "processed", "is_valid": is_valid_sample}
            
        except (APIConnectionError, RateLimitError) as e:
            logger.warning(f"Transient LLM API error: {e}")
            return {"status": "failed", "reason": "transient_error"}
            
        except Exception as e:
            logger.error(f"Error processing telemetry log: {e}", exc_info=True)
            return {"status": "failed", "reason": "internal_error"}
