import 'dart:ffi';
import 'package:ffi/ffi.dart';

// 定义 C 语言函数签名
typedef LlamaInitNative = Pointer<Void> Function(Pointer<Utf8> modelPath);
typedef LlamaInitDart = Pointer<Void> Function(Pointer<Utf8> modelPath);

typedef LlamaFreeNative = Void Function(Pointer<Void> context);
typedef LlamaFreeDart = void Function(Pointer<Void> context);

typedef LlamaInferNative = Pointer<Utf8> Function(Pointer<Void> context, Pointer<Utf8> prompt);
typedef LlamaInferDart = Pointer<Utf8> Function(Pointer<Void> context, Pointer<Utf8> prompt);

/// Llama.cpp FFI 绑定类，用于加载 C++ 动态库并提供 Dart 接口
class LlamaCppBindings {
  late final DynamicLibrary _lib;
  
  late final LlamaInitDart _llamaInit;
  late final LlamaFreeDart _llamaFree;
  late final LlamaInferDart _llamaInfer;

  LlamaCppBindings(String libraryPath) {
    // 加载动态库 (.so / .dylib / .dll)
    _lib = DynamicLibrary.open(libraryPath);

    // 绑定函数
    _llamaInit = _lib
        .lookup<NativeFunction<LlamaInitNative>>('llama_init_wrapper')
        .asFunction();

    _llamaFree = _lib
        .lookup<NativeFunction<LlamaFreeNative>>('llama_free_wrapper')
        .asFunction();

    _llamaInfer = _lib
        .lookup<NativeFunction<LlamaInferNative>>('llama_infer_wrapper')
        .asFunction();
  }

  /// 初始化模型，返回上下文指针
  Pointer<Void> initModel(String modelPath) {
    final nativePath = modelPath.toNativeUtf8();
    try {
      return _llamaInit(nativePath);
    } finally {
      calloc.free(nativePath);
    }
  }

  /// 释放模型资源
  void freeModel(Pointer<Void> context) {
    if (context != nullptr) {
      _llamaFree(context);
    }
  }

  /// 执行推理
  String infer(Pointer<Void> context, String prompt, {String? grammarSchema}) {
    final nativePrompt = prompt.toNativeUtf8();
    try {
      final nativeResult = _llamaInfer(context, nativePrompt);
      if (nativeResult == nullptr) return "";
      
      final result = nativeResult.toDartString();
      // 注意：在真实的 C++ wrapper 中，返回的字符串如果是在堆上分配的，
      // 需要提供一个 C 函数来释放它，或者在 C++ 侧使用静态/线程局部存储（不推荐）。
      // 这里为了演示，假设 C++ 侧处理了内存或使用 GC。
      return result;
    } finally {
      calloc.free(nativePrompt);
    }
  }
}
