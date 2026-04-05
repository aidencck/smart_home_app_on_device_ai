import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def fix_agent_screen_globals():
    p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')
    with open(p, 'r') as f:
        c = f.read()

    # The errors say `Undefined name 'agentManager'` and `Undefined name 'deviceManager'`
    # This means there are still references to the global variables that no longer exist.
    # We should replace all `agentManager.` with `ref.read(agentManagerProvider).` or `ref.watch` where appropriate.
    
    # We can replace `agentManager.` with `ref.read(agentManagerProvider).` if it's an action,
    # or `ref.watch(agentManagerProvider).` if it's reading state.
    # Same for deviceManager.

    c = c.replace("agentManager.", "ref.read(agentManagerProvider).")
    c = c.replace("deviceManager.", "ref.read(deviceManagerProvider).")

    with open(p, 'w') as f:
        f.write(c)

fix_agent_screen_globals()
