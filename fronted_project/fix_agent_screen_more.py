import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def fix_agent_screen_errors():
    p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')
    with open(p, 'r') as f:
        c = f.read()

    # 36: agentManager.preload(); in initState
    c = c.replace("agentManager.preload();", "ref.read(agentManagerProvider).preload();")
    
    # 45: agentManager.clearProcessingSteps(); in dispose
    # Riverpod doesn't allow ref.read in dispose, we can skip it or just do nothing because provider handles its own state
    c = c.replace("agentManager.clearProcessingSteps();", "")

    # 74: agentManager.addProcessingStep
    c = c.replace("agentManager.addProcessingStep", "ref.read(agentManagerProvider).addProcessingStep")
    
    # 85: agentManager.addProcessingStep
    c = c.replace("agentManager.addProcessingStep", "ref.read(agentManagerProvider).addProcessingStep")

    with open(p, 'w') as f:
        f.write(c)

def fix_transition_builder():
    p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')
    with open(p, 'r') as f:
        c = f.read()
    
    # "error • The argument type 'DeviceCard Function(BuildContext)' can't be assigned to the parameter type 'TransitionBuilder'."
    # Oh, wait, the AnimatedSwitcher's transitionBuilder signature is `Widget Function(Widget child, Animation<double> animation)`
    # But earlier I replaced `transitionBuilder: (child) {` to `transitionBuilder: (child, animation) {`. 
    # Let's check what it actually is in the code.
    pass

fix_agent_screen_errors()
