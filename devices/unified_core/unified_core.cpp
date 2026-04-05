#include "unified_core.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

// 模拟的全局状态
static bool is_initialized = false;
static char* current_db_path = NULL;

bool unified_core_init(const char* db_path) {
    if (db_path == NULL) return false;
    
    // 如果已经初始化过，先清理旧的资源
    if (current_db_path != NULL) {
        free(current_db_path);
    }
    
    current_db_path = strdup(db_path);
    is_initialized = true;
    
    // 初始化 SQLite / Isar 连接
    printf("[UnifiedCore] Initialized with DB path: %s\n", db_path);
    return true;
}

void unified_core_cleanup() {
    if (current_db_path != NULL) {
        free(current_db_path);
        current_db_path = NULL;
    }
    is_initialized = false;
    printf("[UnifiedCore] Cleaned up resources.\n");
}

int evaluate_intent_complexity(const char* intent_text) {
    if (!is_initialized || intent_text == NULL) return 0;
    
    // 简单的意图判断：包含复杂条件词（如 "如果", "当...时", "明天"）则上云
    if (strstr(intent_text, "如果") != NULL || strstr(intent_text, "当") != NULL) {
        printf("[UnifiedCore] Complex intent detected, routing to cloud.\n");
        return 0; // 上云
    }
    
    // 开关灯等直接命令留给本地 0.5B
    printf("[UnifiedCore] Simple intent detected, handling locally.\n");
    return 1; // 本地
}

char* collect_batch_device_states() {
    if (!is_initialized) return strdup("{}");
    
    // 模拟从数据库获取批量变更数据
    // 实际上应该查询 Isar/SQLite 的未同步日志
    const char* batch_json = "{\"updates\": [{\"device_id\": \"light_1\", \"state\": \"on\", \"last_update_ts\": 1680000000}]}";
    
    // 返回动态分配的内存，Dart 端通过 unified_core_free_string 释放
    return strdup(batch_json);
}

void unified_core_free_string(char* str) {
    if (str != NULL) {
        free(str);
    }
}

bool execute_device_command(const char* device_id, const char* action_json) {
    if (!is_initialized || device_id == NULL || action_json == NULL) return false;
    
    // 模拟通过 MQTT/Matter 协议下发物理设备控制
    printf("[UnifiedCore] Executing command on device %s: %s\n", device_id, action_json);
    return true;
}