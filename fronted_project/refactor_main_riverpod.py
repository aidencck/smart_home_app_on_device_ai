import os

main_path = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib/main.dart'
with open(main_path, 'r') as f:
    content = f.read()

content = content.replace("import 'presentation/app.dart';", "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'presentation/app.dart';")
content = content.replace("runApp(const SmartHomeApp());", "runApp(const ProviderScope(child: SmartHomeApp()));")

# Remove global instances
content = content.replace("final deviceManager = DeviceManager(VirtualDeviceService());", "")
content = content.replace("final agentManager = AgentManager();", "")
content = content.replace("agentManager.preload();", "// Preload can be handled later")

with open(main_path, 'w') as f:
    f.write(content)
