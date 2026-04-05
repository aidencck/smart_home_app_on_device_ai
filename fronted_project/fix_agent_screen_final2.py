import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def fix_agent_screen_more_final_errors():
    p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')
    with open(p, 'r') as f:
        c = f.read()
    
    # 637: deviceManager
    c = c.replace("deviceManager.getDeviceByName", "ref.read(deviceManagerProvider).getDeviceByName")
    
    # 638: TransitionBuilder
    c = c.replace("transitionBuilder: (child, animation) {", "transitionBuilder: (Widget child, Animation<double> animation) {")

    with open(p, 'w') as f:
        f.write(c)

fix_agent_screen_more_final_errors()
