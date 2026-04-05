import os
import re

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'
p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')

with open(p, 'r') as f:
    c = f.read()

# The error is:
# error • The argument type 'SmartDevice' can't be assigned to the parameter type 'Map<String, dynamic>'.
# at lines 590:39 and 595:39

# Let's check lines 590 and 595.
lines = c.split('\n')
print(lines[585:600])

