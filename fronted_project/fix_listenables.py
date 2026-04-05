import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def fix_home_shell():
    p = os.path.join(lib_dir, 'presentation/home_shell.dart')
    with open(p, 'r') as f:
        c = f.read()
    c = c.replace("ConsumerState<HomeShell>", "ConsumerState<HomeShell>")
    # We replaced "State<" with "ConsumerState<", so `ConsumerState<HomeShell> createState` became `ConsumerConsumerState<`... let's fix it
    c = c.replace("ConsumerConsumerState", "ConsumerState")
    
    with open(p, 'w') as f:
        f.write(c)

def fix_devices_page():
    p = os.path.join(lib_dir, 'presentation/pages/devices_page.dart')
    with open(p, 'r') as f:
        c = f.read()
    c = c.replace("ConsumerConsumerState", "ConsumerState")
    
    c = c.replace(
        "return ListenableBuilder(",
        "final deviceManager = ref.watch(deviceManagerProvider);\n    return Builder("
    )
    c = c.replace("listenable: deviceManager,", "")
    c = c.replace("builder: (context, _) {", "builder: (context) {")
    with open(p, 'w') as f:
        f.write(c)

def fix_agent_screen():
    p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')
    with open(p, 'r') as f:
        c = f.read()
    c = c.replace("ConsumerConsumerState", "ConsumerState")
    
    c = c.replace(
        "return ListenableBuilder(",
        "final agentManager = ref.watch(agentManagerProvider);\n    return Builder("
    )
    c = c.replace("listenable: agentManager,", "")
    c = c.replace("builder: (context, _) {", "builder: (context) {")
    with open(p, 'w') as f:
        f.write(c)

def fix_device_detail_sheet():
    p = os.path.join(lib_dir, 'presentation/widgets/device_detail_sheet.dart')
    with open(p, 'r') as f:
        c = f.read()
    c = c.replace(
        "return ListenableBuilder(",
        "final deviceManager = ref.watch(deviceManagerProvider);\n    return Builder("
    )
    c = c.replace("listenable: deviceManager,", "")
    c = c.replace("builder: (context, _) {", "builder: (context) {")
    with open(p, 'w') as f:
        f.write(c)


fix_home_shell()
fix_devices_page()
fix_agent_screen()
fix_device_detail_sheet()
