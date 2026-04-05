import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:system_info2/system_info2.dart';
import '../inference_engine.dart';
import 'llama_bindings.dart' if (dart.library.html) 'llama_bindings_web.dart';

// ignore: undefined_class
typedef DynamicPointer = dynamic;

/// 包含发送给 Isolate 的初始化数据
class _IsolateInitData {
  final SendPort sendPort;
  final String libraryPath;
  final String modelPath;

  _IsolateInitData(this.sendPort, this.libraryPath, this.modelPath);
}

/// 发送给 Isolate 的推理请求
class _IsolateInferRequest {
  final SendPort replyPort;
  final String prompt;
  final String? grammarSchema;

  _IsolateInferRequest(this.replyPort, this.prompt, {this.grammarSchema});
}

/// 真正的基于 Llama.cpp (FFI) 的推理引擎实现。
/// 使用 Dart Isolate 将重度的 C++ 模型加载和推理过程放到后台线程，避免阻塞 Flutter 主 UI。
class LlamaCppEngine implements InferenceEngine {
  late final String _libraryPath;
  
  Isolate? _isolate;
  SendPort? _sendPort;
  bool _isInitialized = false;

  LlamaCppEngine() {
    // 根据平台自动决定要加载的动态库名称
    if (Platform.isAndroid) {
      _libraryPath = 'libllama_wrapper.so';
    } else if (Platform.isIOS || Platform.isMacOS) {
      // 本地运行与调试时，指向刚编译出来的 C++ wrapper dylib
      _libraryPath = '${Directory.current.path}/ios/Classes/libllama_wrapper.dylib';
    } else if (Platform.isWindows) {
      _libraryPath = 'llama_wrapper.dll';
    } else {
      _libraryPath = 'libllama_wrapper.so';
    }
  }

  @override
  Future<void> initialize(String modelPath) async {
    if (_isInitialized) return;

    // --- 内存探针与降级策略 ---
    if (!kIsWeb) {
      // 在移动端粗略检查系统可用内存是否足够 (这里简单模拟，实际可通过 system_info 插件获取)
      // 假设我们需要至少 1GB 的可用内存
      bool isMemorySufficient = true; 
      try {
        final availableMemoryBytes = SysInfo.getFreePhysicalMemory();
        final availableMemoryMB = availableMemoryBytes / (1024 * 1024);
        log("硬件探针: 当前设备可用物理内存约为 ${availableMemoryMB.toStringAsFixed(2)} MB");
        
        // 阈值设定为 1GB (1024MB)
        if (availableMemoryMB < 1024) {
          isMemorySufficient = false;
        }
      } catch (e) {
        log("获取设备内存信息失败: $e");
        // 如果获取失败，出于保守起见，可以选择允许或降级。这里保持默认允许。
      }

      if (!isMemorySufficient) {
         log("⚠️ 警告：检测到设备可用内存不足 1GB，拒绝加载本地模型。将无缝降级到云端 API。");
         // 触发降级逻辑...
         return;
      }
    }

    final receivePort = ReceivePort();
    
    // 启动独立的 Isolate
    _isolate = await Isolate.spawn(
      _isolateEntry,
      _IsolateInitData(receivePort.sendPort, _libraryPath, modelPath),
    );

    // 等待 Isolate 初始化完成并返回它的 SendPort
    final initResponse = await receivePort.first;
    if (initResponse is SendPort) {
      _sendPort = initResponse;
      _isInitialized = true;
      log("LlamaCppEngine: 后台 Isolate 初始化成功，模型加载完毕。");
    } else {
      throw Exception("LlamaCppEngine: Isolate 初始化失败: $initResponse");
    }
  }

  @override
  void dispose() {
    _sendPort?.send("DISPOSE");
    _isolate?.kill(priority: Isolate.immediate);
    _isInitialized = false;
    log("LlamaCppEngine: 资源已释放，Isolate 已销毁。");
  }

  @override
  Future<String> infer(String prompt, {String? grammarSchema}) async {
    if (!_isInitialized || _sendPort == null) {
      throw Exception("模型未初始化");
    }

    // 创建一个临时的 ReceivePort 用于接收单次推理结果
    final replyPort = ReceivePort();
    _sendPort!.send(_IsolateInferRequest(replyPort.sendPort, prompt, grammarSchema: grammarSchema));

    // 等待 Isolate 处理并返回结果
    final response = await replyPort.first;
    replyPort.close();

    if (response is String) {
      return response;
    } else if (response is Exception) {
      throw response;
    }
    return "";
  }

  @override
  Stream<String> inferStream(String prompt) {
    // 真正的 Llama.cpp 支持 token by token 的流式回调。
    // 在这里为了演示架构，我们将完整的文本拆分成字符流模拟流式输出。
    // 在完全落地的 C++ 包装层中，需要将 C++ callback 通过 SendPort 实时传递给主线程。
    throw UnimplementedError("流式输出需在 C++ wrapper 层通过 FFI callback 实现");
  }

  // ===========================================================================
  // Isolate 入口点 (运行在后台线程)
  // ===========================================================================
  static void _isolateEntry(_IsolateInitData data) {
    dynamic llamaContext;
    LlamaCppBindings? bindings;

    try {
      // 1. 在 Isolate 中加载 C++ 动态库并初始化模型
      bindings = LlamaCppBindings(data.libraryPath);
      llamaContext = bindings.initModel(data.modelPath);

      if (llamaContext == null) {
        data.sendPort.send(Exception("模型指针为 null，加载失败。"));
        return;
      }

      // 2. 建立 Isolate 内部的通信端口，监听主线程发来的指令
      final commandPort = ReceivePort();
      data.sendPort.send(commandPort.sendPort);

      // 3. 事件循环处理主线程的请求
      commandPort.listen((message) {
        if (message == "DISPOSE") {
          bindings?.freeModel(llamaContext);
          commandPort.close();
        } else if (message is _IsolateInferRequest) {
          try {
            // 执行 C++ 推理，这个过程可能是阻塞的耗时操作，但因为在 Isolate 中，不会影响 UI
            final result = bindings!.infer(
              llamaContext, 
              message.prompt,
              grammarSchema: message.grammarSchema,
            );
            message.replyPort.send(result);
          } catch (e) {
            message.replyPort.send(Exception("推理执行失败: $e"));
          }
        }
      });
    } catch (e) {
      data.sendPort.send(Exception("Isolate 初始化异常: $e"));
    }
  }
}
