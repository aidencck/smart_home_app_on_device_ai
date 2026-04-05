#ifndef UNIFIED_CORE_H
#define UNIFIED_CORE_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// 初始化端侧核心逻辑库
bool unified_core_init(const char* db_path);

// 清理核心逻辑库，释放全局资源
void unified_core_cleanup();

// 本地意图路由判断 (Local Router)
// 返回 1 表示本地处理，0 表示需要上云
int evaluate_intent_complexity(const char* intent_text);

// 批量状态同步：收集当前 Isar 数据库中积压的设备状态
// 返回 JSON 格式的 Batch 字符串 (需由调用方使用 unified_core_free_string 释放)
char* collect_batch_device_states();

// 释放由 unified_core 分配的字符串内存
void unified_core_free_string(char* str);

// 解析并下发控制指令给设备
bool execute_device_command(const char* device_id, const char* action_json);

#ifdef __cplusplus
}
#endif

#endif // UNIFIED_CORE_H