import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

with open(os.path.join(lib_dir, 'main.dart'), 'r') as f:
    lines = f.readlines()

new_lines = [
    "import 'package:flutter/material.dart';\n",
    "import 'presentation/app.dart';\n",
    "import 'application/application.dart';\n",
    "import 'services/virtual_device_service.dart';\n",
    "\n",
    "// 全局实例，注入虚拟服务（后续可替换为 RemoteDeviceService）\n",
    "final deviceManager = DeviceManager(VirtualDeviceService());\n",
    "final agentManager = AgentManager();\n",
    "\n",
    "void main() {\n",
    "  WidgetsFlutterBinding.ensureInitialized();\n",
    "  agentManager.preload();\n",
    "  runApp(const SmartHomeApp());\n",
    "}\n"
]

with open(os.path.join(lib_dir, 'main.dart'), 'w') as f:
    f.writelines(new_lines)

# Also fix imports in managers
for file in ['application/device_manager.dart', 'application/agent_manager.dart']:
    path = os.path.join(lib_dir, file)
    with open(path, 'r') as f:
        content = f.read()
    content = content.replace("import 'widgets/widgets.dart';", "import '../presentation/widgets/widgets.dart';")
    content = content.replace("import 'pages/pages.dart';", "import '../presentation/pages/pages.dart';")
    with open(path, 'w') as f:
        f.write(content)

# And fix fallback_intent_service.dart imports
path = os.path.join(lib_dir, 'features/agent/fallback_intent_service.dart')
with open(path, 'r') as f:
    content = f.read()
if "import '../../application/device_manager.dart';" not in content:
    content = "import '../../application/device_manager.dart';\n" + content
    with open(path, 'w') as f:
        f.write(content)

print("Fixed main.dart and imports")
