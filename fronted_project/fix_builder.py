import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def fix_agent_screen_animated_switcher():
    p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')
    with open(p, 'r') as f:
        c = f.read()

    # Still: error • The argument type 'DeviceCard Function(BuildContext)' can't be assigned to the parameter type 'TransitionBuilder'.
    # In agent_screen.dart around 638, the error points to line 638.
    # Ah! In AnimatedSwitcher, the `layoutBuilder` takes `Widget Function(Widget?, List<Widget>)`
    # and `transitionBuilder` takes `Widget Function(Widget child, Animation<double> animation)`
    
    # Wait, maybe it's not AnimatedSwitcher. Let me check what's on line 638.
    
    # The earlier `cat` showed:
    #                     child: ListenableBuilder(
    #                       listenable: ref.read(deviceManagerProvider),
    #                       builder: (context) {
    #                         return DeviceCard(

    # So the builder for ListenableBuilder was `builder: (context) {`
    # Did my previous python script run successfully?
    # It replaced `builder: (context) {\n                        return DeviceCard(`
    # Let me just check the exact lines.

    lines = c.split('\n')
    for i, line in enumerate(lines):
        if "builder: (context) {" in line:
            lines[i] = line.replace("builder: (context) {", "builder: (context, child) {")

    with open(p, 'w') as f:
        f.write('\n'.join(lines))

fix_agent_screen_animated_switcher()
