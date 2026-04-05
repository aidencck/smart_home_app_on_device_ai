#include "unified_core.h"
#include <iostream>
#include <string>
#include <cstring>

// 内部状态
static bool is_engine_initialized = false;
static std::string current_model_path = "";

extern "C" {

int init_engine(const char* model_path) {
    if (!model_path) {
        std::cerr << "[UnifiedCore] Error: model_path is null." << std::endl;
        return -1;
    }
    
    current_model_path = model_path;
    is_engine_initialized = true;
    
    // TODO: 在这里对接 llama.cpp 的初始化逻辑
    // 示例代码:
    // llama_backend_init();
    // llama_model_params model_params = llama_model_default_params();
    // struct llama_model * model = llama_load_model_from_file(model_path, model_params);
    // ...
    
    std::cout << "[UnifiedCore] Engine initialized successfully with model: " << current_model_path << std::endl;
    return 0;
}

const char* process_intent(const char* context_json) {
    if (!is_engine_initialized) {
        std::cerr << "[UnifiedCore] Error: Engine not initialized." << std::endl;
        const char* err_msg = "{\"error\": \"Engine not initialized\"}";
        char* result = new char[strlen(err_msg) + 1];
        strcpy(result, err_msg);
        return result;
    }
    
    if (!context_json) {
        std::cerr << "[UnifiedCore] Error: context_json is null." << std::endl;
        const char* err_msg = "{\"error\": \"Empty context\"}";
        char* result = new char[strlen(err_msg) + 1];
        strcpy(result, err_msg);
        return result;
    }

    std::cout << "[UnifiedCore] Processing intent with context: " << context_json << std::endl;

    // TODO: 在这里对接 llama.cpp 进行推断，并结合 GBNF 语法约束生成结构化 JSON
    // 1. 将 context_json 转换为 Prompt，加入 system prompt 等
    // 2. 配置 llama.cpp 的采样参数，并加载 GBNF grammar (限制输出为特定 JSON 格式)
    // 3. 执行推断 (llama_decode, llama_sample_token 等)
    // 4. 提取生成的 JSON 文本

    // 下面为模拟的推断结果
    std::string mock_response = "{\"intent\": \"turn_on_light\", \"confidence\": 0.95, \"target\": \"AA:BB:CC:DD:EE:01\"}";
    
    // 分配内存以返回给 Flutter 侧 (调用方需要调用 free_result 释放内存)
    char* result = new char[mock_response.length() + 1];
    strcpy(result, mock_response.c_str());
    return result;
}

void free_result(const char* result) {
    if (result) {
        delete[] result;
    }
}

} // extern "C"
