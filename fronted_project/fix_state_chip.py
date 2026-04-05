import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def fix_agent_screen_state_chip():
    p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')
    with open(p, 'r') as f:
        c = f.read()

    replace_from = """  Widget _buildStateChip(SmartDevice state, ColorScheme colorScheme, {bool isAfter = false}) {
    final isOn = state.isOn == true;
    final temp = (state as HasTemperature).temperature;
    
    String stateText = isOn ? "开启" : "关闭";
    if (isOn && temp != null) {
      stateText += " ($temp°C)";
    }"""
    
    replace_to = """  Widget _buildStateChip(SmartDevice state, ColorScheme colorScheme, {bool isAfter = false}) {
    final isOn = state.isOn == true;
    int? temp;
    if (state is HasTemperature) {
      temp = state.temperature;
    }
    
    String stateText = isOn ? "开启" : "关闭";
    if (isOn && temp != null) {
      stateText += " ($temp°C)";
    }"""
    
    c = c.replace(replace_from, replace_to)
    
    with open(p, 'w') as f:
        f.write(c)

fix_agent_screen_state_chip()
