import os
import re

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def process_file(file_path):
    with open(file_path, 'r') as f:
        content = f.read()

    # Make it a ConsumerWidget if it's StatelessWidget
    if "extends StatelessWidget" in content:
        content = content.replace("extends StatelessWidget", "extends ConsumerWidget")
        content = content.replace("Widget build(BuildContext context)", "Widget build(BuildContext context, WidgetRef ref)")
        
        if "import 'package:flutter_riverpod/flutter_riverpod.dart';" not in content:
            content = "import 'package:flutter_riverpod/flutter_riverpod.dart';\n" + content
        if "import '../../application/providers.dart';" not in content and "import '../application/providers.dart';" not in content:
            if "pages/" in file_path or "widgets/" in file_path:
                content = "import '../../application/providers.dart';\n" + content
            else:
                content = "import '../application/providers.dart';\n" + content
    
    # Make it a ConsumerStatefulWidget if it's StatefulWidget
    if "extends StatefulWidget" in content:
        content = content.replace("extends StatefulWidget", "extends ConsumerStatefulWidget")
        content = re.sub(r"State<([^>]+)>", r"ConsumerState<\1>", content)
        
        if "import 'package:flutter_riverpod/flutter_riverpod.dart';" not in content:
            content = "import 'package:flutter_riverpod/flutter_riverpod.dart';\n" + content
        if "import '../../application/providers.dart';" not in content and "import '../application/providers.dart';" not in content:
            if "pages/" in file_path or "widgets/" in file_path:
                content = "import '../../application/providers.dart';\n" + content
            else:
                content = "import '../application/providers.dart';\n" + content

    with open(file_path, 'w') as f:
        f.write(content)

for root, _, files in os.walk(os.path.join(lib_dir, 'presentation')):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
