import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'
p = os.path.join(lib_dir, 'application/agent_manager.dart')

with open(p, 'r') as f:
    c = f.read()

lines = c.split('\n')
for i, line in enumerate(lines):
    if "preload" in line:
        print("\n".join(lines[i:i+30]))
        break
