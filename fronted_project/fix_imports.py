import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

for file in ['application/device_manager.dart', 'application/agent_manager.dart']:
    path = os.path.join(lib_dir, file)
    with open(path, 'r') as f:
        content = f.read()
    content = content.replace("import 'widgets/widgets.dart';", "import '../presentation/widgets/widgets.dart';")
    content = content.replace("import 'pages/pages.dart';", "import '../presentation/pages/pages.dart';")
    with open(path, 'w') as f:
        f.write(content)

print("Fixed imports")
