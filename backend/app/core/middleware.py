import time
import uuid
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
from app.core.logger import logger

class RequestLogMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        request_id = str(uuid.uuid4())
        # Inject request_id into request state
        request.state.request_id = request_id
        
        start_time = time.time()
        
        # logger.info(f"Request started: {request.method} {request.url.path} | req_id: {request_id}")
        
        try:
            response = await call_next(request)
            process_time = time.time() - start_time
            response.headers["X-Process-Time"] = str(process_time)
            response.headers["X-Request-ID"] = request_id
            
            logger.info(
                f"Request completed: {request.method} {request.url.path} "
                f"- Status: {response.status_code} "
                f"- Duration: {process_time:.4f}s "
                f"- req_id: {request_id}"
            )
            return response
        except Exception as e:
            process_time = time.time() - start_time
            logger.error(
                f"Request failed: {request.method} {request.url.path} "
                f"- Duration: {process_time:.4f}s "
                f"- req_id: {request_id} "
                f"- Error: {str(e)}"
            )
            raise e
