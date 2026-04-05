import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def clean_agent_screen_more():
    p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')
    with open(p, 'r') as f:
        c = f.read()

    # 637: error • Undefined name 'deviceManager'
    # Wait, earlier I did `c.replace("deviceManager.getDeviceByName", "ref.read(deviceManagerProvider).getDeviceByName")`
    # Let's just do `deviceManager` -> `ref.read(deviceManagerProvider)`
    c = c.replace("deviceManager.getDeviceByName", "ref.read(deviceManagerProvider).getDeviceByName")
    
    # Let's replace any lingering `deviceManager.` inside agent_screen
    c = c.replace("deviceManager.devices", "ref.read(deviceManagerProvider).devices")
    c = c.replace("deviceManager.", "ref.read(deviceManagerProvider).")
    
    # 638: error • The argument type 'DeviceCard Function(BuildContext)' can't be assigned to the parameter type 'TransitionBuilder'.
    # Oh! `transitionBuilder: (child, animation) {`
    # Did it get replaced to `(Widget child, Animation<double> animation)`?
    # Let's just fix AnimatedSwitcher manually
    
    with open(p, 'w') as f:
        f.write(c)

clean_agent_screen_more()
