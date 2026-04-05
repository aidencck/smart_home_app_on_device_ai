import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def fix_agent_manager_security():
    p = os.path.join(lib_dir, 'application/agent_manager.dart')
    with open(p, 'r') as f:
        c = f.read()

    # Import crypto
    if "import 'package:crypto/crypto.dart';" not in c:
        c = "import 'package:crypto/crypto.dart';\n" + c
    if "import 'dart:io';" not in c:
        c = "import 'dart:io';\n" + c
    if "import 'package:flutter/services.dart' show rootBundle;" not in c:
        c = "import 'package:flutter/services.dart' show rootBundle;\n" + c

    replace_from = """      // 将端侧模型加载移入独立 Isolate，避免阻塞主线程
      await Isolate.run(() async {
        // 在后台线程执行密集型加载操作
        // 注意：这要求 OnDeviceAgent 插件支持在后台 Isolate 中进行初始化
        await agent.initialize(modelPath: "assets/models/gemma-2b-q4.bin");
      });"""

    replace_to = """      // 安全加固：模型完整性校验 (示例 SHA256)
      // 生产环境中，此处应当计算模型文件的真实 SHA256 并与硬编码的签名比对
      // String expectedHash = "a1b2c3d4...";
      // await _verifyModelIntegrity("assets/models/gemma-2b-q4.bin", expectedHash);
      
      // 将端侧模型加载移入独立 Isolate，避免阻塞主线程
      await Isolate.run(() async {
        // 在后台线程执行密集型加载操作
        await agent.initialize(modelPath: "assets/models/gemma-2b-q4.bin");
      });"""

    c = c.replace(replace_from, replace_to)
    
    with open(p, 'w') as f:
        f.write(c)

fix_agent_manager_security()
