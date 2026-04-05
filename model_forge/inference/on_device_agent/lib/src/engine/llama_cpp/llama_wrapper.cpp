#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// 假设这里引入了真实的 llama.cpp 头文件
// #include "llama.h"

// 导出为 C 风格的接口，防止 C++ name mangling，以便 Dart FFI 能够找到符号
#ifdef __cplusplus
extern "C" {
#endif

// -----------------------------------------------------------------------------
// 注意：以下是包装层的示例代码，展示了如何将 llama.cpp 复杂的 API 
// 封装成极简的 C 接口供 Dart FFI 调用。
// -----------------------------------------------------------------------------

// 模拟的上下文结构体
typedef struct {
    char* model_path;
    // llama_model *model;
    // llama_context *ctx;
} my_llama_context;

// 1. 初始化模型
void* llama_init_wrapper(const char* model_path, bool use_mmap, bool use_mlock, int n_gpu_layers, int n_threads) {
    printf("[C++] 正在加载模型: %s (mmap: %d, gpu_layers: %d, threads: %d)\n", model_path, use_mmap, n_gpu_layers, n_threads);
    
    my_llama_context* ctx = (my_llama_context*)malloc(sizeof(my_llama_context));
    if (!ctx) return NULL;
    
    // 在真实代码中：
    // llama_backend_init();
    // llama_model_params model_params = llama_model_default_params();
    // ctx->model = llama_load_model_from_file(model_path, model_params);
    // ...

    // 模拟分配
    ctx->model_path = strdup(model_path);
    
    printf("[C++] 模型加载成功。\n");
    return (void*)ctx;
}

// 2. 释放资源
void llama_free_wrapper(void* context) {
    if (!context) return;
    my_llama_context* ctx = (my_llama_context*)context;
    
    printf("[C++] 正在释放模型: %s\n", ctx->model_path);
    
    // 在真实代码中：
    // llama_free(ctx->ctx);
    // llama_free_model(ctx->model);
    // llama_backend_free();
    
    free(ctx->model_path);
    free(ctx);
    printf("[C++] 模型资源已释放。\n");
}

// 3. 执行推理 (阻塞式调用)
const char* llama_infer_wrapper(void* context, const char* prompt) {
    if (!context || !prompt) return NULL;
    my_llama_context* ctx = (my_llama_context*)context;
    
    printf("[C++] 收到推理请求，Prompt长度: %zu\n", strlen(prompt));
    
    // 在真实代码中，这里会调用 llama_decode() 并进入生成循环
    // 不断采样下一个 token，直到遇到 EOS。
    
    // 我们在这里硬编码返回一个合法的 JSON 字符串以模拟模型输出
    // 注意：这里分配的内存如果在 Dart 侧转为 String 后，必须由 C++ 侧释放。
    // 为了简化演示，通常的做法是让 Dart 传入一个足够大的 buffer，或者在 C++ 内部使用静态/线程局部缓存。
    
    static char static_buffer[1024]; // 仅做演示，线程不安全。真实项目请通过回调或 Dart 提供 buffer。
    
    if (strstr(prompt, "有点热") != NULL) {
        snprintf(static_buffer, sizeof(static_buffer), "{\"device_id\": \"ac_1\", \"action\": \"set_temp\", \"value\": 24}");
    } else {
        snprintf(static_buffer, sizeof(static_buffer), "{\"device_id\": \"light_1\", \"action\": \"turn_on\"}");
    }
    
    printf("[C++] 推理完成，返回结果: %s\n", static_buffer);
    return static_buffer;
}

#ifdef __cplusplus
}
#endif
