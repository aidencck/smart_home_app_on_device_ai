import os
import re

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def fix_agent_screen_remaining():
    p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')
    with open(p, 'r') as f:
        c = f.read()
    
    # 324: agentManager.isProcessing
    c = c.replace("agentManager.isProcessing", "ref.watch(agentManagerProvider).isProcessing")
    
    # 331, 333: agentManager.clearProcessingSteps
    c = c.replace("agentManager.clearProcessingSteps()", "ref.read(agentManagerProvider).clearProcessingSteps()")
    c = c.replace("agentManager.processingSteps.length", "ref.watch(agentManagerProvider).processingSteps.length")
    c = c.replace("agentManager.processingSteps", "ref.watch(agentManagerProvider).processingSteps")
    
    # 347, 351, 368, 380, 399: agentManager.chatHistory
    c = c.replace("agentManager.chatHistory", "ref.watch(agentManagerProvider).chatHistory")
    
    # 637, 641: deviceManager.getDeviceByName
    c = c.replace("deviceManager.getDeviceByName", "ref.read(deviceManagerProvider).getDeviceByName")
    
    # Fix TransitionBuilder type error:
    # error • The argument type 'DeviceCard Function(BuildContext)' can't be assigned to the parameter type 'TransitionBuilder'.
    # In AnimatedSwitcher transitionBuilder:
    c = c.replace(
        "transitionBuilder: (child) {",
        "transitionBuilder: (child, animation) {"
    )
    
    with open(p, 'w') as f:
        f.write(c)

fix_agent_screen_remaining()
