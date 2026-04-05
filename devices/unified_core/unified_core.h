#ifndef UNIFIED_CORE_H
#define UNIFIED_CORE_H

#ifdef __cplusplus
extern "C" {
#endif

// 初始化推理引擎 (例如: llama.cpp)
// model_path: 模型文件的绝对路径
// 返回值: 0 表示成功，非 0 表示失败
int init_engine(const char* model_path);

// 处理意图推断请求
// context_json: 包含当前上下文信息的 JSON 字符串 (如设备状态、用户指令等)
// 返回值: 返回推断结果的 JSON 字符串指针 (需要调用 free_result 释放内存)
const char* process_intent(const char* context_json);

// 释放 process_intent 返回的字符串内存
void free_result(const char* result);

#ifdef __cplusplus
}
#endif

#endif // UNIFIED_CORE_H
