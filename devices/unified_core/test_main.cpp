#include "unified_core.h"
#include <stdio.h>
#include <stdlib.h>

int main() {
    printf("=== 测试 Unified Core 端侧引擎 ===\n");
    
    // 1. 初始化数据库路径
    bool init_success = unified_core_init("/var/data/smart_home.db");
    if (init_success) {
        printf("数据库初始化成功！\n\n");
    }

    // 2. 测试简单意图：本地处理
    printf("--- 测试意图解析: [打开客厅的灯] ---\n");
    int result1 = evaluate_intent_complexity("打开客厅的灯");
    printf("解析结果: %s\n\n", result1 == 1 ? "【本地端侧处理】" : "【上报云端大模型】");

    // 3. 测试复杂意图：上报云端
    printf("--- 测试意图解析: [如果明天下雨出门前提醒我带伞] ---\n");
    int result2 = evaluate_intent_complexity("如果明天下雨出门前提醒我带伞");
    printf("解析结果: %s\n\n", result2 == 1 ? "【本地端侧处理】" : "【上报云端大模型】");

    // 4. 测试下发设备指令
    printf("--- 测试设备控制指令下发 ---\n");
    bool cmd_success = execute_device_command("light_living_room_1", "{\"state\": \"on\", \"brightness\": 80}");
    if (cmd_success) {
        printf("指令下发成功！\n\n");
    }

    // 5. 测试批量获取设备状态
    printf("--- 测试获取设备批量同步状态 ---\n");
    char* batch_data = collect_batch_device_states();
    printf("当前同步队列数据: %s\n", batch_data);
    unified_core_free_string(batch_data);
    printf("\n");

    // 6. 清理资源
    unified_core_cleanup();
    printf("=== 测试结束 ===\n");
    
    return 0;
}
