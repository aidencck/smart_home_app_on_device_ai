import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def fix_agent_screen_listenable_builder():
    p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')
    with open(p, 'r') as f:
        c = f.read()

    # Wait, the error is:
    # error • The argument type 'DeviceCard Function(BuildContext)' can't be assigned to the parameter type 'TransitionBuilder'.
    # Ah! In ListenableBuilder, the parameter is `builder: (BuildContext context, Widget? child)`
    # But I replaced `builder: (context, _) {` with `builder: (context) {`.
    # And then maybe the type inferencer is confused because `ListenableBuilder` expects `(context, child)`.
    # Let's fix that.
    c = c.replace("builder: (context) {\n                        return DeviceCard(", "builder: (context, child) {\n                        return DeviceCard(")
    
    with open(p, 'w') as f:
        f.write(c)

fix_agent_screen_listenable_builder()
