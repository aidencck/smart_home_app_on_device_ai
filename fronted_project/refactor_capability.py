import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

# device_manager.dart
dm_path = os.path.join(lib_dir, 'application/device_manager.dart')
with open(dm_path, 'r') as f:
    content = f.read()

content = content.replace("device is AcDevice", "device is HasTemperature")
content = content.replace("device.temperature = temp", "(device as HasTemperature).temperature = temp")
content = content.replace("device.temperature !=", "(device as HasTemperature).temperature !=")

with open(dm_path, 'w') as f:
    f.write(content)

# device_detail_sheet.dart
dds_path = os.path.join(lib_dir, 'presentation/widgets/device_detail_sheet.dart')
with open(dds_path, 'r') as f:
    content = f.read()

content = content.replace("deviceId.startsWith('light')", "device is HasBrightness")
content = content.replace("deviceId.startsWith('ac')", "device is HasTemperature")

with open(dds_path, 'w') as f:
    f.write(content)

# device_card.dart
dc_path = os.path.join(lib_dir, 'presentation/widgets/device_card.dart')
with open(dc_path, 'r') as f:
    content = f.read()

content = content.replace("device is AcDevice", "device is HasTemperature")
content = content.replace("(device as AcDevice).temperature", "(device as HasTemperature).temperature")

with open(dc_path, 'w') as f:
    f.write(content)

# device_manager_test.dart
test_path = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/test/device_manager_test.dart'
with open(test_path, 'r') as f:
    content = f.read()
content = content.replace("is AcDevice) as AcDevice", "is HasTemperature) as SmartDevice")
content = content.replace("as AcDevice).temperature", "as HasTemperature).temperature")
with open(test_path, 'w') as f:
    f.write(content)

# fallback_intent_service.dart
fis_path = os.path.join(lib_dir, 'features/agent/fallback_intent_service.dart')
with open(fis_path, 'r') as f:
    content = f.read()
# Wait, fallback_intent_service sets temperature by name keywords, so it doesn't do "is AcDevice". It just passes it to setDeviceStateById

print("Capability refactor applied")
