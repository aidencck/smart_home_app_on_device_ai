import os
import re

main_file = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib/main.dart'
lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

with open(main_file, 'r') as f:
    content = f.read()

# Define class start patterns
patterns = [
    ('DeviceManager', r'class DeviceManager extends ChangeNotifier \{', 'application/device_manager.dart'),
    ('AgentManager', r'class AgentManager extends ChangeNotifier \{', 'application/agent_manager.dart'),
    ('SmartHomeApp', r'class SmartHomeApp extends StatelessWidget \{', 'presentation/app.dart'),
    ('HomeShell', r'class HomeShell extends StatefulWidget \{', 'presentation/home_shell.dart'),
    ('DeviceCard', r'class DeviceCard extends StatelessWidget \{', 'presentation/widgets/device_card.dart'),
    ('DeviceDetailSheet', r'class DeviceDetailSheet extends StatelessWidget \{', 'presentation/widgets/device_detail_sheet.dart'),
    ('DevicesPage', r'class DevicesPage extends StatefulWidget \{', 'presentation/pages/devices_page.dart'),
    ('ScenesPage', r'class ScenesPage extends StatelessWidget \{', 'presentation/pages/scenes_page.dart'),
    ('AutomationsPage', r'class AutomationsPage extends StatelessWidget \{', 'presentation/pages/automations_page.dart'),
    ('ProfilePage', r'class ProfilePage extends StatelessWidget \{', 'presentation/pages/profile_page.dart'),
    ('HomeManagementPage', r'class HomeManagementPage extends StatefulWidget \{', 'presentation/pages/home_management_page.dart'),
    ('GatewayIntegrationPage', r'class GatewayIntegrationPage extends StatelessWidget \{', 'presentation/pages/gateway_integration_page.dart'),
    ('NotificationCenterPage', r'class NotificationCenterPage extends StatelessWidget \{', 'presentation/pages/notification_center_page.dart'),
    ('CloudStoragePage', r'class CloudStoragePage extends StatelessWidget \{', 'presentation/pages/cloud_storage_page.dart'),
    ('GeneralSettingsPage', r'class GeneralSettingsPage extends StatelessWidget \{', 'presentation/pages/general_settings_page.dart'),
    ('AgentScreen', r'class AgentScreen extends StatefulWidget \{', 'presentation/pages/agent_screen.dart'),
]

# Find positions
positions = []
for name, pattern, filepath in patterns:
    match = re.search(pattern, content)
    if match:
        positions.append((match.start(), name, filepath))

positions.sort(key=lambda x: x[0])

sections = {}
for i in range(len(positions)):
    start = positions[i][0]
    end = positions[i+1][0] if i+1 < len(positions) else len(content)
    name = positions[i][1]
    filepath = positions[i][2]
    
    class_def = content[start:end]
    # Remove global instantiations like "final deviceManager = ..." from the end
    class_def = re.sub(r'final \w+Manager = [^;]+;\s*', '', class_def)
    
    sections[name] = {
        'content': class_def,
        'filepath': filepath
    }

# Ensure directories exist
dirs_to_create = ['application', 'presentation/pages', 'presentation/widgets']
for d in dirs_to_create:
    os.makedirs(os.path.join(lib_dir, d), exist_ok=True)

# Generate index files to simplify imports
index_files = {
    'application/application.dart': "export 'device_manager.dart';\nexport 'agent_manager.dart';\n",
    'presentation/pages/pages.dart': "export 'devices_page.dart';\nexport 'scenes_page.dart';\nexport 'automations_page.dart';\nexport 'profile_page.dart';\nexport 'home_management_page.dart';\nexport 'gateway_integration_page.dart';\nexport 'notification_center_page.dart';\nexport 'cloud_storage_page.dart';\nexport 'general_settings_page.dart';\nexport 'agent_screen.dart';\n",
    'presentation/widgets/widgets.dart': "export 'device_card.dart';\nexport 'device_detail_sheet.dart';\n",
}
for path, cnt in index_files.items():
    with open(os.path.join(lib_dir, path), 'w') as f:
        f.write(cnt)

default_imports = """import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:on_device_agent/on_device_agent.dart';
import '../../models/device.dart';
import '../../services/device_service.dart';
import '../../services/virtual_device_service.dart';
import '../../theme/figma_colors.dart';
import '../../features/agent/fallback_intent_service.dart';
import '../../application/application.dart';
import '../widgets/widgets.dart';
import '../pages/pages.dart';
import '../../main.dart'; // for global variables if needed
"""

for name, data in sections.items():
    full_path = os.path.join(lib_dir, data['filepath'])
    # Adjust relative paths based on depth
    depth = data['filepath'].count('/')
    imports = default_imports
    if depth == 1: # application or presentation
        imports = imports.replace('../../', '../').replace('../widgets', 'widgets').replace('../pages', 'pages')
    with open(full_path, 'w') as f:
        f.write(imports + '\n' + data['content'])

# Generate a new main.dart
new_main_content = content[:positions[0][0]]
new_main_content += """
import 'presentation/app.dart';
import 'application/application.dart';
import 'services/virtual_device_service.dart';

// 全局实例，注入虚拟服务（后续可替换为 RemoteDeviceService）
final deviceManager = DeviceManager(VirtualDeviceService());
final agentManager = AgentManager();
"""
with open(main_file, 'w') as f:
    f.write(new_main_content)

print("Split completed.")
