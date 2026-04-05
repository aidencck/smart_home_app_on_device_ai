import os
import re

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

# 1. Update device_manager.dart
dm_path = os.path.join(lib_dir, 'application/device_manager.dart')
with open(dm_path, 'r') as f:
    dm_content = f.read()

dm_content = dm_content.replace('Future<Map<String, dynamic>?> setDeviceStateById', 'Future<Map<String, SmartDevice>?> setDeviceStateById')
dm_content = dm_content.replace('final beforeState = device.toJson();', 'final beforeState = device.clone();')
dm_content = dm_content.replace('final afterState = device.toJson();', 'final afterState = device.clone();')
with open(dm_path, 'w') as f:
    f.write(dm_content)

# 2. Update agent_manager.dart
am_path = os.path.join(lib_dir, 'application/agent_manager.dart')
with open(am_path, 'r') as f:
    am_content = f.read()

am_content = am_content.replace('List<Map<String, dynamic>> affectedDevices = [];', 'List<SmartDevice> affectedDevices = [];')
am_content = am_content.replace('Map<String, dynamic>? beforeState;', 'SmartDevice? beforeState;')
am_content = am_content.replace('Map<String, dynamic>? afterState;', 'SmartDevice? afterState;')
am_content = am_content.replace("afterState['name']", "afterState.name")

with open(am_path, 'w') as f:
    f.write(am_content)

# 3. Update fallback_intent_service.dart
fis_path = os.path.join(lib_dir, 'features/agent/fallback_intent_service.dart')
with open(fis_path, 'r') as f:
    fis_content = f.read()

fis_content = fis_content.replace('List<Map<String, dynamic>> affectedDevices;', 'List<SmartDevice> affectedDevices;')
fis_content = fis_content.replace('Map<String, dynamic>? beforeState;', 'SmartDevice? beforeState;')
fis_content = fis_content.replace('Map<String, dynamic>? afterState;', 'SmartDevice? afterState;')
fis_content = fis_content.replace('final Map<String, dynamic>? beforeState;', 'final SmartDevice? beforeState;')
fis_content = fis_content.replace('final Map<String, dynamic>? afterState;', 'final SmartDevice? afterState;')
fis_content = fis_content.replace("afterState!['name']", "afterState!.name")
fis_content = fis_content.replace("afterState!['temperature']", "(afterState as AcDevice).temperature")
fis_content = fis_content.replace("device['id']", "device.id")
fis_content = fis_content.replace("device['name']", "device.name")

with open(fis_path, 'w') as f:
    f.write(fis_content)

# 4. agent_screen.dart rendering
# In agent_screen.dart, affectedDevices is saved as 'devices' in the map chatHistory
asc_path = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')
with open(asc_path, 'r') as f:
    asc_content = f.read()

# Make sure it iterates List<SmartDevice> instead of map
asc_content = asc_content.replace("final devices = message['devices'] as List<dynamic>;", "final devices = message['devices'] as List<SmartDevice>;")
asc_content = asc_content.replace("final device = d as Map<String, dynamic>;", "final device = d as SmartDevice;")

with open(asc_path, 'w') as f:
    f.write(asc_content)

print("Fixed Map to SmartDevice usages.")
