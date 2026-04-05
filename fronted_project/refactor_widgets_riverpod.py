import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def fix_widget(file_path):
    with open(file_path, 'r') as f:
        content = f.read()

    # Imports
    if "import 'package:flutter_riverpod/flutter_riverpod.dart';" not in content:
        content = "import 'package:flutter_riverpod/flutter_riverpod.dart';\n" + content
    
    # Needs providers
    if "import '../../application/providers.dart';" not in content:
        content = content.replace("import '../../application/application.dart';", "import '../../application/application.dart';\nimport '../../application/providers.dart';")
        content = content.replace("import '../application/application.dart';", "import '../application/application.dart';\nimport '../application/providers.dart';")

    # Replace StatelessWidget -> ConsumerWidget
    content = content.replace("extends StatelessWidget", "extends ConsumerWidget")
    content = content.replace("Widget build(BuildContext context)", "Widget build(BuildContext context, WidgetRef ref)")
    
    # Replace StatefulWidget -> ConsumerStatefulWidget
    content = content.replace("extends StatefulWidget", "extends ConsumerStatefulWidget")
    content = content.replace("extends State<", "extends ConsumerState<")
    content = content.replace("State<", "ConsumerState<") # for the generic part
    
    # Remove ListenableBuilder
    if "ListenableBuilder(" in content:
        # It's tricky to replace ListenableBuilder correctly via regex without an AST parser,
        # but for specific known files we can just replace deviceManager and agentManager usages.
        pass

    with open(file_path, 'w') as f:
        f.write(content)

pages = [
    'presentation/home_shell.dart',
    'presentation/pages/devices_page.dart',
    'presentation/pages/agent_screen.dart',
    'presentation/widgets/device_detail_sheet.dart',
    'presentation/widgets/device_card.dart',
]

for p in pages:
    fix_widget(os.path.join(lib_dir, p))

# Let's fix specific files manually where ListenableBuilder is used
