import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'
p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')

with open(p, 'r') as f:
    c = f.read()

# Lines 667, 668:
# error • The operator '[]' isn't defined for the type 'SmartDevice' •
# This must be inside `_buildStateChip` or similar. Let's find `['on']` or `['temperature']` or similar that wasn't replaced.
# Ah, I replaced:
# c.replace("state['temperature'] as int", "(state as HasTemperature).temperature")
# Maybe the original code didn't have `as int`? Let's check.

c = c.replace("state['temperature']", "(state as HasTemperature).temperature")
c = c.replace("state['brightness']", "(state as HasBrightness).brightness")
c = c.replace("state['on']", "state.isOn")

with open(p, 'w') as f:
    f.write(c)

print("Fixed lingering array access on SmartDevice")
