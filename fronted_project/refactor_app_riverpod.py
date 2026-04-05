import os

app_path = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib/presentation/app.dart'
with open(app_path, 'r') as f:
    content = f.read()

content = content.replace("class SmartHomeApp extends StatelessWidget", "class SmartHomeApp extends ConsumerWidget")
content = content.replace("import 'home_shell.dart';", "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'home_shell.dart';")
content = content.replace("Widget build(BuildContext context)", "Widget build(BuildContext context, WidgetRef ref)")

with open(app_path, 'w') as f:
    f.write(content)
