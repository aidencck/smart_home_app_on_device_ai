# 后端云核心 (FastAPI) API 接口字典

这份字典列出了云端服务（`backed_project`）与端侧 App (`fronted_project`) 交互的核心接口，供前端及其他微服务对接时查阅。所有接口返回均遵循 `BaseResponse` 标准。

---

## 1. AI 兜底与大模型交互

### `POST /api/v1/ai/chat`
**功能**：云端大模型兜底。当端侧意图判断无法处理长尾/复杂请求时，端侧对数据脱敏后上传到此接口。

**鉴权要求**：`Bearer Token (JWT)`

**请求体 (Request Body)**
```json
{
  "command_id": "uuid-v4-1234",
  "query": "明天早上8点半帮我把主卧的空调开到26度，并且拉开窗帘",
  "hardware_level": "home_123", // 将在中间件被强制重写为用户的 home_id
  "context": [
    {
      "device_id": "ac_master_1",
      "state": "off",
      "last_update_ts": 1715000000
    },
    {
      "device_id": "curtain_master_1",
      "state": "closed",
      "last_update_ts": 1714900000
    }
  ]
}
```

**响应体 (Response Body)**
```json
{
  "code": 0,
  "message": "Command processed successfully",
  "data": {
    "command_id": "uuid-v4-1234",
    "actions": [
      { "device_id": "ac_master_1", "action": "on", "parameters": {"temp": 26}, "delay_ms": 28800000 },
      { "device_id": "curtain_master_1", "action": "open", "parameters": {}, "delay_ms": 28800000 }
    ],
    "fallback_message": "好的，已经为您预约明早8点半打开主卧空调和窗帘。"
  }
}
```

---

## 2. 设备状态同步与管理

### `POST /api/v1/devices/shadow/batch`
**功能**：批量更新设备云端影子状态。基于 Version Clock 和 Redis Pipeline 实现，处理高并发防覆盖。

**鉴权要求**：`Bearer Token (JWT)`

**请求体 (Request Body)**
```json
{
  "updates": [
    {
      "device_id": "light_living_1",
      "state": "on",
      "last_update_ts": 1715000005, // 递增的版本号或精确到毫秒的时间戳
      "is_high_risk": false
    },
    {
      "device_id": "door_lock_1",
      "state": "locked",
      "last_update_ts": 1715000006,
      "is_high_risk": true // 高危设备，TTL 极短，拒绝缓存
    }
  ]
}
```

**响应体 (Response Body)**
```json
{
  "code": 0,
  "message": "Shadow batch updated successfully",
  "data": {
    "success_count": 2,
    "stale_count": 0,
    "total_processed": 2
  }
}
```

### `POST /api/v1/admin/devices/rpc`
**功能**：统一的 JSON-RPC 风格设备 CRUD 管理接口（供管理后台或端侧同步设备列表使用）。

**鉴权要求**：`Bearer Token (JWT - Tenant Admin)`

**请求体 (Request Body) 示例 (Create)**
```json
{
  "method": "device.create",
  "params": {
    "product_id": 1,
    "device_name": "客厅智能台灯",
    "mac_address": "00:1A:2B:3C:4D:5E"
  }
}
```

**响应体 (Response Body) 示例**
```json
{
  "code": 0,
  "message": "Success",
  "data": {
    "id": 1024,
    "product_id": 1,
    "device_name": "客厅智能台灯",
    "secret": "a1b2c3d4e5f6g7h8", // 设备鉴权密钥
    "is_deleted": false
  }
}
```

---

## 3. 数据飞轮与模型迭代

### `POST /api/v1/data/telemetry`
**功能**：端侧接收用户 Opt-in 授权后，异步上报脱敏失败日志，供云端 BackgroundTasks 或 Celery 进行清洗和模型打分。

**鉴权要求**：`Bearer Token (JWT)`

**请求体 (Request Body)**
```json
{
  "session_id": "sess_9999",
  "user_query": "打开那个什么，能吹风的",
  "intent_parsed": "unknown",
  "action_taken": "none",
  "user_feedback": -1, // 用户点击了👎
  "device_context_hash": "sha256_abcdef..."
}
```

**响应体 (Response Body)**
```json
{
  "code": 0,
  "message": "Telemetry accepted and queued",
  "data": {
    "status": "queued"
  }
}
```

### `GET /api/v1/ota/check`
**功能**：端侧冷启动时检查最新的 GGUF/模型补丁版本。

**鉴权要求**：`Bearer Token (JWT)`

**查询参数 (Query Parameters)**
*   `current_version`: string (e.g., "1.0.2")
*   `hardware_level`: string (e.g., "mac_m4", "iphone_15_pro")

**响应体 (Response Body)**
```json
{
  "code": 0,
  "message": "Update available",
  "data": {
    "update_available": true,
    "latest_version": "1.1.0",
    "download_url": "https://cdn.smarthome.com/models/smarthome_qwen_0.5b_q4_k_m_v1.1.0.gguf",
    "md5_checksum": "d41d8cd98f00b204e9800998ecf8427e",
    "force_update": false
  }
}
```