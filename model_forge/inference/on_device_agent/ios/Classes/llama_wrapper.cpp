#include "llama.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vector>
#include <string>

// C++ wrappers around llama.cpp for Dart FFI
extern "C" {

struct LlamaWrapperContext {
    llama_model* model;
    llama_context* ctx;
    llama_sampler* smpl;
    std::string model_path;
};

// 1. 初始化模型
void* llama_init_wrapper(const char* model_path, bool use_mmap, bool use_mlock, int n_gpu_layers, int n_threads) {
    printf("[llama.cpp wrapper] 初始化后端...\n");
    llama_backend_init();

    LlamaWrapperContext* wrapper_ctx = new LlamaWrapperContext();
    wrapper_ctx->model_path = model_path;

    printf("[llama.cpp wrapper] 加载模型: %s (mmap: %d, gpu_layers: %d, threads: %d)\n", model_path, use_mmap, n_gpu_layers, n_threads);
    llama_model_params model_params = llama_model_default_params();
    // Enable Metal on iOS/macOS or other GPU backends if available
    model_params.n_gpu_layers = n_gpu_layers; 
    model_params.use_mmap = use_mmap;
    model_params.use_mlock = use_mlock;

    wrapper_ctx->model = llama_model_load_from_file(model_path, model_params);
    if (!wrapper_ctx->model) {
        printf("[llama.cpp wrapper] 模型加载失败!\n");
        delete wrapper_ctx;
        return nullptr;
    }

    llama_context_params ctx_params = llama_context_default_params();
    ctx_params.n_ctx = 2048; // Context size
    ctx_params.n_threads = n_threads;
    ctx_params.n_threads_batch = n_threads;
    
    wrapper_ctx->ctx = llama_init_from_model(wrapper_ctx->model, ctx_params);
    if (!wrapper_ctx->ctx) {
        printf("[llama.cpp wrapper] Context 初始化失败!\n");
        llama_model_free(wrapper_ctx->model);
        delete wrapper_ctx;
        return nullptr;
    }
    
    // 初始化采样器
    llama_sampler_chain_params smpl_params = llama_sampler_chain_default_params();
    wrapper_ctx->smpl = llama_sampler_chain_init(smpl_params);
    llama_sampler_chain_add(wrapper_ctx->smpl, llama_sampler_init_top_k(40));
    llama_sampler_chain_add(wrapper_ctx->smpl, llama_sampler_init_top_p(0.9f, 1));
    llama_sampler_chain_add(wrapper_ctx->smpl, llama_sampler_init_temp(0.4f));
    llama_sampler_chain_add(wrapper_ctx->smpl, llama_sampler_init_dist(LLAMA_DEFAULT_SEED));

    printf("[llama.cpp wrapper] 模型加载并初始化成功。\n");
    return (void*)wrapper_ctx;
}

// 2. 释放资源
void llama_free_wrapper(void* context) {
    if (!context) return;
    LlamaWrapperContext* wrapper_ctx = static_cast<LlamaWrapperContext*>(context);
    
    printf("[llama.cpp wrapper] 释放模型: %s\n", wrapper_ctx->model_path.c_str());
    
    if (wrapper_ctx->smpl) {
        llama_sampler_free(wrapper_ctx->smpl);
    }
    if (wrapper_ctx->ctx) {
        llama_free(wrapper_ctx->ctx);
    }
    if (wrapper_ctx->model) {
        llama_model_free(wrapper_ctx->model);
    }
    
    delete wrapper_ctx;
    llama_backend_free();
    
    printf("[llama.cpp wrapper] 资源已释放。\n");
}

// 3. 执行推理
const char* llama_infer_wrapper(void* context, const char* prompt) {
    if (!context || !prompt) return nullptr;
    LlamaWrapperContext* wrapper_ctx = static_cast<LlamaWrapperContext*>(context);
    
    printf("[llama.cpp wrapper] 开始推理, Prompt长度: %zu\n", strlen(prompt));

    // 获取 token 词表
    const llama_vocab* vocab = llama_model_get_vocab(wrapper_ctx->model);
    
    // 将 prompt 转为 tokens
    std::string prompt_str(prompt);
    int n_prompt_tokens = -llama_tokenize(vocab, prompt_str.c_str(), prompt_str.length(), NULL, 0, true, true);
    std::vector<llama_token> prompt_tokens(n_prompt_tokens);
    if (llama_tokenize(vocab, prompt_str.c_str(), prompt_str.length(), prompt_tokens.data(), prompt_tokens.size(), true, true) < 0) {
        printf("[llama.cpp wrapper] Tokenize failed!\n");
        return nullptr;
    }

    // 初始化 batch
    llama_batch batch = llama_batch_get_one(prompt_tokens.data(), prompt_tokens.size());
    
    // Evaluate prompt
    if (llama_decode(wrapper_ctx->ctx, batch) != 0) {
        printf("[llama.cpp wrapper] llama_decode failed!\n");
        return nullptr;
    }

    // 用于保存生成结果的静态 buffer (仅限单线程演示，生产环境应通过 Dart 传指针)
    static std::string result_buffer;
    result_buffer.clear();
    
    int n_cur = batch.n_tokens;
    int n_predict = 128; // 最大生成 token 数
    
    while (n_cur <= n_predict) {
        // 采样下一个 token
        llama_token new_token_id = llama_sampler_sample(wrapper_ctx->smpl, wrapper_ctx->ctx, -1);
        
        // 判断是否生成结束 (EOS)
        if (llama_vocab_is_eog(vocab, new_token_id)) {
            break;
        }
        
        // Token 转字符串
        char buf[128];
        int n = llama_token_to_piece(vocab, new_token_id, buf, sizeof(buf), 0, true);
        if (n > 0) {
            result_buffer.append(buf, n);
        }
        
        // 准备下一个 batch
        batch = llama_batch_get_one(&new_token_id, 1);
        
        if (llama_decode(wrapper_ctx->ctx, batch) != 0) {
            printf("[llama.cpp wrapper] llama_decode failed during generation!\n");
            break;
        }
        
        n_cur += 1;
    }

    printf("[llama.cpp wrapper] 推理完成。生成长度: %d tokens\n", n_cur - (int)prompt_tokens.size());
    return result_buffer.c_str();
}

} // extern "C"