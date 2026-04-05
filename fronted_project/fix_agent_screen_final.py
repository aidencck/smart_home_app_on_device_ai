import os
import re

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def fix_agent_screen_final_errors():
    p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')
    with open(p, 'r') as f:
        c = f.read()

    # The errors say:
    # 36, 45, 74, 85: Undefined name 'agentManager'
    # 637: Undefined name 'deviceManager'
    
    # We replaced `agentManager.` with `ref.read...` but maybe there was `agentManager` without `.` ?
    # Let's see what's on line 36.
    
    # Actually I will just define them in the methods if they are used multiple times or just do a regex replace
    
    c = c.replace("agentManager = ", "final agentManager = ")
    c = c.replace("deviceManager = ", "final deviceManager = ")

    # We need to manually fix these lines because previous replace might have failed
    
    lines = c.split('\n')
    
    for i, line in enumerate(lines):
        if "agentManager.preload();" in line and "ref." not in line:
            lines[i] = line.replace("agentManager", "ref.read(agentManagerProvider)")
        elif "agentManager.clearProcessingSteps();" in line and "ref." not in line:
            lines[i] = line.replace("agentManager", "ref.read(agentManagerProvider)")
        elif "agentManager.addProcessingStep" in line and "ref." not in line:
            lines[i] = line.replace("agentManager", "ref.read(agentManagerProvider)")
        elif "deviceManager.getDeviceByName" in line and "ref." not in line:
            lines[i] = line.replace("deviceManager", "ref.read(deviceManagerProvider)")
            
    c = '\n'.join(lines)
    
    # The TransitionBuilder error:
    c = c.replace("transitionBuilder: (child) {", "transitionBuilder: (child, animation) {")
    c = c.replace("FadeTransition(opacity: const AlwaysStoppedAnimation(1), child: child)", "FadeTransition(opacity: animation, child: child)")

    with open(p, 'w') as f:
        f.write(c)

fix_agent_screen_final_errors()
