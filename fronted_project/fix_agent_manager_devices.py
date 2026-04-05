import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'
p = os.path.join(lib_dir, 'application/agent_manager.dart')

with open(p, 'r') as f:
    c = f.read()

# See how agent_manager handles deviceManager
c = c.replace('availableDevices: deviceManager.devices.map((d) => d.toJson()).toList(),', 'availableDevices: deviceManager.devices.map((d) => d.toJson()).toList(),')

with open(p, 'w') as f:
    f.write(c)
