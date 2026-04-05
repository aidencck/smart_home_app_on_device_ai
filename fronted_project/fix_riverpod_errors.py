import os
import re

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def fix_agent_screen():
    p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')
    with open(p, 'r') as f:
        c = f.read()

    # The issue: "Undefined name 'agentManager'" because agentManager was global, now it's ref.read(agentManagerProvider)
    # Inside _AgentScreenState (now ConsumerState)
    c = c.replace("agentManager.isInitializing", "ref.read(agentManagerProvider).isInitializing")
    c = c.replace("agentManager.isError", "ref.read(agentManagerProvider).isError")
    c = c.replace("agentManager.handleSendMessage", "ref.read(agentManagerProvider).handleSendMessage")
    
    # Same for deviceManager in agent_screen
    c = c.replace("deviceManager.toggleDevice", "ref.read(deviceManagerProvider).toggleDevice")

    with open(p, 'w') as f:
        f.write(c)

def fix_home_shell():
    p = os.path.join(lib_dir, 'presentation/home_shell.dart')
    with open(p, 'r') as f:
        c = f.read()

    c = c.replace("agentManager.isInitializing", "ref.watch(agentManagerProvider).isInitializing")
    c = c.replace("agentManager.preload", "ref.read(agentManagerProvider).preload")
    
    with open(p, 'w') as f:
        f.write(c)

def fix_devices_page():
    p = os.path.join(lib_dir, 'presentation/pages/devices_page.dart')
    with open(p, 'r') as f:
        c = f.read()
    
    # Fix 'Widget Function(BuildContext, WidgetRef)' isn't a valid override of 'State.build'
    # For ConsumerState, build signature is `Widget build(BuildContext context)` without WidgetRef.
    # WidgetRef is available as `ref` inside the ConsumerState class.
    c = c.replace("Widget build(BuildContext context, WidgetRef ref)", "Widget build(BuildContext context)")
    
    c = c.replace("deviceManager.toggleDevice", "ref.read(deviceManagerProvider).toggleDevice")
    
    with open(p, 'w') as f:
        f.write(c)

def fix_agent_screen_build():
    p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')
    with open(p, 'r') as f:
        c = f.read()
    
    # Same fix for build signature
    c = c.replace("Widget build(BuildContext context, WidgetRef ref)", "Widget build(BuildContext context)")
    
    with open(p, 'w') as f:
        f.write(c)

def fix_home_shell_build():
    p = os.path.join(lib_dir, 'presentation/home_shell.dart')
    with open(p, 'r') as f:
        c = f.read()
    
    # Same fix for build signature
    c = c.replace("Widget build(BuildContext context, WidgetRef ref)", "Widget build(BuildContext context)")
    
    with open(p, 'w') as f:
        f.write(c)

fix_agent_screen()
fix_home_shell()
fix_devices_page()
fix_agent_screen_build()
fix_home_shell_build()
