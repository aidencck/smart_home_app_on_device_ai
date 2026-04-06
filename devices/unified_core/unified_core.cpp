#include "unified_core.h"
#include <iostream>
#include <string>
#include <cstring>
#include <vector>

// 假设已经提供 llama.h
#include "llama.h"

// 内部状态
static bool is_engine_initialized = false;
static std::string current_model_path = "";
static llama_model* model = nullptr;
static llama_context* ctx = nullptr;
static llama_grammar* grammar = nullptr; // 用于保存 GBNF grammar

extern "C" {

int init_engine(const char* model_path) {
    if (!model_path) {
        std::cerr << "[UnifiedCore] Error: model_path is null." << std::endl;
        return -1;
    }
    
    current_model_path = model_path;
    
    // 1. 初始化后端
    llama_backend_init();
    
    // 2. 设置模型参数并加载模型
    llama_model_params model_params = llama_model_default_params();
    // 可以在此处调整 model_params，例如将模型层卸载到 GPU (n_gpu_layers)
    model = llama_load_model_from_file(model_path, model_params);
    if (!model) {
        std::cerr << "[UnifiedCore] Error: Failed to load model from " << model_path << std::endl;
        return -1;
    }
    
    // 3. 设置上下文参数并创建上下文
    llama_context_params ctx_params = llama_context_default_params();
    ctx_params.n_ctx = 2048; // 设置最大上下文长度
    ctx = llama_new_context_with_model(model, ctx_params);
    if (!ctx) {
        std::cerr << "[UnifiedCore] Error: Failed to create context." << std::endl;
        llama_free_model(model);
        model = nullptr;
        return -1;
    }

    // (可选) 在此处可以通过 llama_grammar_init 等 API 加载 grammar 以约束输出
    // grammar = llama_grammar_init(...);

    is_engine_initialized = true;
    std::cout << "[UnifiedCore] Engine initialized successfully with model: " << current_model_path << std::endl;
    return 0;
}

const char* process_intent(const char* context_json) {
    if (!is_engine_initialized || !ctx || !model) {
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

    // 1. 组装 Prompt
    std::string prompt = "You are a smart home assistant. Based on the following context, extract the user intent and output in valid JSON format.\n\nContext:\n";
    prompt += context_json;
    prompt += "\n\nResponse (JSON):";

    // 2. Tokenize 将文本转为 token 序列
    std::vector<llama_token> tokens;
    tokens.resize(prompt.length() + 2);
    // 注意: llama_tokenize 的具体参数可能因 llama.cpp 版本而略有不同
    int n_tokens = llama_tokenize(model, prompt.c_str(), prompt.length(), tokens.data(), tokens.size(), true, false);
    if (n_tokens < 0) {
        tokens.resize(-n_tokens);
        n_tokens = llama_tokenize(model, prompt.c_str(), prompt.length(), tokens.data(), tokens.size(), true, false);
    }
    tokens.resize(n_tokens);

    // 3. 创建 batch，送入模型计算 (Decode)
    llama_batch batch = llama_batch_get_one(tokens.data(), n_tokens, 0, 0);
    if (llama_decode(ctx, batch) != 0) {
        std::cerr << "[UnifiedCore] Error: llama_decode failed." << std::endl;
        const char* err_msg = "{\"error\": \"Inference failed\"}";
        char* result = new char[strlen(err_msg) + 1];
        strcpy(result, err_msg);
        return result;
    }

    // 4. 自回归生成循环
    std::string response = "";
    int n_cur = n_tokens;
    const int max_tokens = 512; // 限制最大生成长度

    while (n_cur <= n_tokens + max_tokens) {
        auto n_vocab = llama_n_vocab(model);
        auto* logits = llama_get_logits_ith(ctx, batch.n_tokens - 1);

        // 准备候选 token 数据
        std::vector<llama_token_data> candidates;
        candidates.reserve(n_vocab);
        for (llama_token token_id = 0; token_id < n_vocab; token_id++) {
            candidates.push_back(llama_token_data{token_id, logits[token_id], 0.0f});
        }
        llama_token_data_array candidates_p = { candidates.data(), candidates.size(), false };

        // 5. 使用 grammar 约束采样 (如果设置了的话)
        if (grammar) {
            llama_sample_grammar(ctx, &candidates_p, grammar);
        }

        // 贪心采样获取最高概率的 token
        llama_token new_token_id = llama_sample_token_greedy(ctx, &candidates_p);

        // 如果遇到结束符 (EOG/EOS)，停止生成
        if (llama_token_is_eog(model, new_token_id)) {
            break;
        }

        // 将 token 转换回文本
        char buf[128];
        int n_chars = llama_token_to_piece(model, new_token_id, buf, sizeof(buf), 0, false);
        if (n_chars >= 0) {
            response.append(buf, n_chars);
        }

        // 如果应用了 grammar，需要让 grammar 接受该 token
        if (grammar) {
            llama_grammar_accept_token(ctx, grammar, new_token_id);
        }

        // 准备预测下一个 token
        // 清空当前 batch，并将新的 token 作为输入
        llama_batch_clear(&batch);
        llama_batch_add(&batch, new_token_id, n_cur, {0}, true);

        if (llama_decode(ctx, batch) != 0) {
            std::cerr << "[UnifiedCore] Error: llama_decode failed during generation." << std::endl;
            break;
        }

        n_cur++;
    }

    // 如果未生成任何内容，提供错误回退
    if (response.empty()) {
        response = "{\"error\": \"Empty response generated\"}";
    } else {
        std::cout << "[UnifiedCore] Inference generated: " << response << std::endl;
    }

    // 6. 分配内存并返回结果
    char* result = new char[response.length() + 1];
    strcpy(result, response.c_str());
    return result;
}

void free_result(const char* result) {
    if (result) {
        delete[] result;
    }
}

// 释放引擎资源
void deinit_engine() {
    if (grammar) {
        llama_grammar_free(grammar);
        grammar = nullptr;
    }
    if (ctx) {
        llama_free(ctx);
        ctx = nullptr;
    }
    if (model) {
        llama_free_model(model);
        model = nullptr;
    }
    llama_backend_free();
    is_engine_initialized = false;
}

} // extern "C"
