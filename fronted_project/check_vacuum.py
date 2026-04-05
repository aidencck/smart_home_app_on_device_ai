import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'
p = os.path.join(lib_dir, 'application/device_manager.dart')

with open(p, 'r') as f:
    c = f.read()

# Let's check device_manager's toJson
# For vacuum device, it extends SmartDevice but doesn't override toJson, so it falls back to SmartDevice.toJson()
# SmartDevice.toJson() returns:
# final data = <String, dynamic>{
#   'id': id,
#   'name': name,
#   'room': room,
#   'type': type.name,
#   'on': isOn,
# };

# But wait, the error is:
# TypeError: Instance of 'VacuumDevice': type 'VacuumDevice' is not a subtype of type 'Map<String, dynamic>?'

# This means somewhere VacuumDevice is being assigned or cast to Map<String, dynamic>?
pass
