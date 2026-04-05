import os

asc_path = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib/presentation/pages/agent_screen.dart'
with open(asc_path, 'r') as f:
    content = f.read()

content = content.replace("msg['devices'] as List<Map<String, dynamic>>?;", "msg['devices'] as List<SmartDevice>?;")

with open(asc_path, 'w') as f:
    f.write(content)
