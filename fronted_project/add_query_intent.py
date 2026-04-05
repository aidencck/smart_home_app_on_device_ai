import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def add_query_devices_intent():
    p = os.path.join(lib_dir, 'features/agent/fallback_intent_service.dart')
    with open(p, 'r') as f:
        c = f.read()

    # Add a query intent
    replace_from = """    final tvPattern = RegExp(r'(电视|电影|剧)');"""
    replace_to = """    final tvPattern = RegExp(r'(电视|电影|剧)');
    final queryDevicesPattern = RegExp(r'(哪些|什么|所有).*(设备|东西)');"""
    
    c = c.replace(replace_from, replace_to)
    
    replace_from2 = """    if (acPattern.hasMatch(text) || (isContinuing && text.contains("高一点"))) {"""
    replace_to2 = """    if (queryDevicesPattern.hasMatch(text)) {
      final devices = deviceManager.devices;
      final names = devices.map((d) => d.name).join('、');
      responseText = "🤖 您目前有以下设备：$names。";
    } else if (acPattern.hasMatch(text) || (isContinuing && text.contains("高一点"))) {"""
    
    c = c.replace(replace_from2, replace_to2)
    
    with open(p, 'w') as f:
        f.write(c)

add_query_devices_intent()
