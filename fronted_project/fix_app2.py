import os

app_path = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib/presentation/app.dart'
with open(app_path, 'r') as f:
    content = f.read()

if "import 'home_shell.dart';" not in content:
    content = "import 'home_shell.dart';\n" + content

with open(app_path, 'w') as f:
    f.write(content)
