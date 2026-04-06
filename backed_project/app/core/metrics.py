from prometheus_client import Counter, Histogram

# Request latency histogram
REQUEST_LATENCY = Histogram(
    'http_request_duration_seconds',
    'HTTP request latency in seconds',
    ['method', 'endpoint']
)

# AI Fallback counters
AI_FALLBACK_COUNT = Counter(
    'ai_fallback_total',
    'Total number of AI fallback requests',
    ['status'] # e.g., 'success', 'failed', 'cache_hit'
)

# Device control metrics
DEVICE_CONTROL_COUNT = Counter(
    'device_control_total',
    'Total number of device control operations',
    ['device_id', 'operation_type']
)

DEVICE_CONTROL_ERROR = Counter(
    'device_control_error_total',
    'Total number of device control errors',
    ['device_id', 'error_type']
)
