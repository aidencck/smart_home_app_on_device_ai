import os
import re

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def fix_agent_screen_final_try():
    p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')
    with open(p, 'r') as f:
        lines = f.readlines()
        
    for i, line in enumerate(lines):
        if "deviceManager" in line and "ref." not in line and "final deviceManager" not in line:
            lines[i] = line.replace("deviceManager", "ref.read(deviceManagerProvider)")
            
    with open(p, 'w') as f:
        f.writelines(lines)
        
fix_agent_screen_final_try()
