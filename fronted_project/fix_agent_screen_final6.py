import os
import re

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def fix_agent_screen_device_manager():
    p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')
    with open(p, 'r') as f:
        c = f.read()

    # The error "Undefined name 'deviceManager'" is on line 637:
    # "deviceManager.getDeviceByName" -> "ref.read(deviceManagerProvider).getDeviceByName"
    c = c.replace("deviceManager.getDeviceByName", "ref.read(deviceManagerProvider).getDeviceByName")

    # For the transitionBuilder error, the previous script might have missed it or misreplaced it.
    # The error is: The argument type 'DeviceCard Function(BuildContext)' can't be assigned to the parameter type 'TransitionBuilder'.
    # A TransitionBuilder is `Widget Function(Widget child, Animation<double> animation)`
    # The code might be:
    # transitionBuilder: (context) { return DeviceCard(...); }
    # Let's just fix it by hand.
    
    # We'll just do a regex replace on transitionBuilder:
    c = re.sub(r"transitionBuilder:\s*\([^\)]+\)\s*\{", "transitionBuilder: (Widget child, Animation<double> animation) {", c)

    with open(p, 'w') as f:
        f.write(c)

fix_agent_screen_device_manager()
