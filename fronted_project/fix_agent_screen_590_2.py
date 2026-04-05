import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'
p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')

with open(p, 'r') as f:
    c = f.read()

# _buildStateChip is probably defined as:
# Widget _buildStateChip(Map<String, dynamic> state, ColorScheme colorScheme, {bool isAfter = false})

c = c.replace("Widget _buildStateChip(Map<String, dynamic> state, ColorScheme colorScheme", "Widget _buildStateChip(SmartDevice state, ColorScheme colorScheme")
c = c.replace("final isOn = state['on'] as bool;", "final isOn = state.isOn;")

# It might have state['temperature'] as int
c = c.replace("state['temperature'] as int", "(state as HasTemperature).temperature")
# state['brightness'] as double
c = c.replace("state['brightness'] as double", "(state as HasBrightness).brightness")

with open(p, 'w') as f:
    f.write(c)

# We also need to fix `test/agent_manager_test.dart`
# error • 1 positional argument expected by 'AgentManager.new', but 0 found
t = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/test/agent_manager_test.dart'
with open(t, 'r') as f:
    tc = f.read()

tc = tc.replace("agentManager = AgentManager();", """
      final virtualDeviceService = VirtualDeviceService();
      final deviceManager = DeviceManager(virtualDeviceService);
      agentManager = AgentManager(deviceManager);
""")
if "import 'package:smart_home_app/application/device_manager.dart';" not in tc:
    tc = "import 'package:smart_home_app/application/device_manager.dart';\n" + tc
if "import 'package:smart_home_app/services/virtual_device_service.dart';" not in tc:
    tc = "import 'package:smart_home_app/services/virtual_device_service.dart';\n" + tc

with open(t, 'w') as f:
    f.write(tc)

