import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def fix_agent_screen_state_chip():
    p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')
    with open(p, 'r') as f:
        c = f.read()

    replace_from = """    int? temp;
    if (state is HasTemperature) {
      temp = state.temperature;
    }"""
    
    replace_to = """    int? temp;
    if (state is HasTemperature) {
      temp = (state as HasTemperature).temperature;
    }"""
    
    c = c.replace(replace_from, replace_to)
    
    with open(p, 'w') as f:
        f.write(c)

fix_agent_screen_state_chip()
