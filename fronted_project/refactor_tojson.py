import os
import re

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

# 1. application/device_manager.dart
dm_path = os.path.join(lib_dir, 'application/device_manager.dart')
with open(dm_path, 'r') as f:
    dm_content = f.read()

# Replace get devices => ...
dm_content = re.sub(r'List<Map<String, dynamic>> get devices => .*?\.toList\(\);', r'List<SmartDevice> get devices => _devices;', dm_content, flags=re.DOTALL)

# Replace getDevicesByName
dm_content = re.sub(r'List<Map<String, dynamic>> getDevicesByName\(String nameKeywords\) \{.*?return _devices.*?\.toList\(\);\s*\}', r'''List<SmartDevice> getDevicesByName(String nameKeywords) {
    return _devices
        .where(
          (d) =>
              d.name.contains(nameKeywords) ||
              d.room.contains(nameKeywords),
        )
        .toList();
  }''', dm_content, flags=re.DOTALL)

# Replace getDeviceByName
dm_content = re.sub(r'Map<String, dynamic>\? getDeviceByName\(String nameKeywords\) \{.*?try \{.*?return \{.*?if \(d is AcDevice\) \'temperature\': d\.temperature,.*?catch \(e\) \{.*?return null;.*?\}', r'''SmartDevice? getDeviceByName(String nameKeywords) {
    try {
      return _devices.firstWhere(
        (d) =>
            d.name.contains(nameKeywords) ||
            d.room.contains(nameKeywords),
      );
    } catch (e) {
      return null;
    }
  }''', dm_content, flags=re.DOTALL)

# Replace setDeviceStateById Map creation to use toJson
dm_content = re.sub(r'''final beforeState = \{.*?if \(device is AcDevice\) \'temperature\': device\.temperature,\s*\};''', r'''final beforeState = device.toJson();''', dm_content, flags=re.DOTALL)
dm_content = re.sub(r'''final afterState = \{.*?if \(device is AcDevice\) \'temperature\': device\.temperature,\s*\};''', r'''final afterState = device.toJson();''', dm_content, flags=re.DOTALL)

with open(dm_path, 'w') as f:
    f.write(dm_content)

# 2. application/agent_manager.dart
am_path = os.path.join(lib_dir, 'application/agent_manager.dart')
with open(am_path, 'r') as f:
    am_content = f.read()

# change `availableDevices: deviceManager.devices` to `availableDevices: deviceManager.devices.map((d) => d.toJson()).toList()`
am_content = am_content.replace('availableDevices: deviceManager.devices,', 'availableDevices: deviceManager.devices.map((d) => d.toJson()).toList(),')

with open(am_path, 'w') as f:
    f.write(am_content)

# 3. presentation/widgets/device_card.dart
dc_path = os.path.join(lib_dir, 'presentation/widgets/device_card.dart')
with open(dc_path, 'r') as f:
    dc_content = f.read()

dc_content = dc_content.replace('final Map<String, dynamic> device;', 'final SmartDevice device;')
dc_content = dc_content.replace("final isOn = device['on'] as bool;", "final isOn = device.isOn;")
dc_content = dc_content.replace("final name = device['name'] as String;", "final name = device.name;")
dc_content = dc_content.replace("final icon = device['icon'] as IconData;", "final icon = device.icon;")
dc_content = dc_content.replace("final room = device['room'] as String?;", "final room = device.room;")
dc_content = dc_content.replace("device.containsKey('temperature')", "device is AcDevice")
dc_content = dc_content.replace("device['temperature']", "(device as AcDevice).temperature")

with open(dc_path, 'w') as f:
    f.write(dc_content)

# 4. presentation/widgets/device_detail_sheet.dart
dds_path = os.path.join(lib_dir, 'presentation/widgets/device_detail_sheet.dart')
with open(dds_path, 'r') as f:
    dds_content = f.read()

dds_content = dds_content.replace("d['id'] == deviceId", "d.id == deviceId")
dds_content = dds_content.replace("final isOn = device['on'] as bool;", "final isOn = device.isOn;")
dds_content = dds_content.replace("final name = device['name'] as String;", "final name = device.name;")
dds_content = dds_content.replace("final room = device['room'] as String;", "final room = device.room;")
dds_content = dds_content.replace("final icon = device['icon'] as IconData;", "final icon = device.icon;")

with open(dds_path, 'w') as f:
    f.write(dds_content)

# 5. presentation/pages/devices_page.dart
dp_path = os.path.join(lib_dir, 'presentation/pages/devices_page.dart')
with open(dp_path, 'r') as f:
    dp_content = f.read()

dp_content = dp_content.replace("deviceManager.toggleDevice(d['id'] as String)", "deviceManager.toggleDevice(d.id)")
dp_content = dp_content.replace("DeviceDetailSheet(deviceId: d['id'] as String)", "DeviceDetailSheet(deviceId: d.id)")

with open(dp_path, 'w') as f:
    f.write(dp_content)

print("SmartDevice JSON logic refactored.")
