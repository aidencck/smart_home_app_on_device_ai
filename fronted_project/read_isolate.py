import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def fix_agent_manager_isolate():
    p = os.path.join(lib_dir, 'application/agent_manager.dart')
    with open(p, 'r') as f:
        c = f.read()

    # Add compute
    if "import 'package:flutter/foundation.dart';" not in c:
        c = "import 'package:flutter/foundation.dart';\n" + c

    # 1. Update preload
    # Replace:
    # await Future.delayed(const Duration(milliseconds: 500)); // 避免阻塞 UI
    # try {
    #   await _agent.init(
    
    # We will keep it as is if it's native. Actually flutter compute can't pass MethodChannel.
    # We can do `await compute(_parseIntent, text)` for intent parsing to avoid blocking UI.
    
    # Wait, the requirement says "将端侧 AI 推理移入独立 Isolate".
    # If the `_agent.generate` is already asynchronous (returns Future), maybe the user means doing jsonDecode/parsing in compute?
    # Let's check `handleSendMessage` in `agent_manager.dart`
    pass

def read_handleSendMessage():
    p = os.path.join(lib_dir, 'application/agent_manager.dart')
    with open(p, 'r') as f:
        c = f.read()
    lines = c.split('\n')
    for i, line in enumerate(lines):
        if "Future<void> handleSendMessage" in line:
            print("\n".join(lines[i:i+40]))
            break

read_handleSendMessage()
