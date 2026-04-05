import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def fix_agent_manager_dispose_error():
    p = os.path.join(lib_dir, 'application/providers.dart')
    with open(p, 'r') as f:
        c = f.read()

    # The error is:
    # DartError: A AgentManager was used after being disposed.
    # Once you have called dispose() on a AgentManager, it can no longer be used.
    
    # In providers.dart, we have:
    # final agentManagerProvider = ChangeNotifierProvider<AgentManager>((ref) {
    #   final deviceManager = ref.watch(deviceManagerProvider);
    #   return AgentManager(deviceManager);
    # });
    
    # Every time deviceManager notifies (e.g. device is toggled),
    # ref.watch(deviceManagerProvider) will cause agentManagerProvider to rebuild!
    # And Riverpod will dispose the old AgentManager and create a new one!
    # That means any ongoing Future in AgentManager will call notifyListeners() on a disposed AgentManager.
    
    # To fix this, agentManager should NOT watch deviceManagerProvider, 
    # but rather read it when needed, or pass the ref directly so it can read it lazily.
    # Actually, AgentManager only needs DeviceManager to fetch devices.
    # Let's change `ref.watch` to `ref.read` in the provider!
    
    replace_from = """final agentManagerProvider = ChangeNotifierProvider<AgentManager>((ref) {
  final deviceManager = ref.watch(deviceManagerProvider);
  return AgentManager(deviceManager);
});"""
    replace_to = """final agentManagerProvider = ChangeNotifierProvider<AgentManager>((ref) {
  final deviceManager = ref.read(deviceManagerProvider);
  return AgentManager(deviceManager);
});"""

    c = c.replace(replace_from, replace_to)
    
    with open(p, 'w') as f:
        f.write(c)

fix_agent_manager_dispose_error()
