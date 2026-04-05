import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def fix_agent_screen_temperature():
    p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')
    with open(p, 'r') as f:
        c = f.read()

    # The issue is inside _buildStateChip
    # Currently it might blindly do `final temp = (state as HasTemperature).temperature;`
    # Let's see the context.
    pass

def read_build_state_chip():
    p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')
    with open(p, 'r') as f:
        lines = f.readlines()
    for i, line in enumerate(lines):
        if "Widget _buildStateChip(" in line:
            print("".join(lines[i:i+30]))
            break

read_build_state_chip()
