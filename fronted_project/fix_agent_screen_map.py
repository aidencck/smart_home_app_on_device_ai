import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'
p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')

with open(p, 'r') as f:
    c = f.read()

# Ah! Lines 435 and 436:
# final beforeState = msg['beforeState'] as Map<String, dynamic>?;
# final afterState = msg['afterState'] as Map<String, dynamic>?;
# Since we changed it to SmartDevice, it should be:
# final beforeState = msg['beforeState'] as SmartDevice?;
# final afterState = msg['afterState'] as SmartDevice?;

c = c.replace("msg['beforeState'] as Map<String, dynamic>?;", "msg['beforeState'] as SmartDevice?;")
c = c.replace("msg['afterState'] as Map<String, dynamic>?;", "msg['afterState'] as SmartDevice?;")

# And let's check what it uses beforeState/afterState for:
# if (beforeState != null && afterState != null) { ... beforeState['name'] ... }
# We need to change that to beforeState.name
c = c.replace("beforeState!['name']", "beforeState!.name")
c = c.replace("afterState!['on'] as bool", "afterState!.isOn")
c = c.replace("afterState!['temperature'] as int", "(afterState as HasTemperature).temperature")
c = c.replace("beforeState!['temperature'] as int", "(beforeState as HasTemperature).temperature")

with open(p, 'w') as f:
    f.write(c)

print("Fixed Map to SmartDevice in agent_screen.dart")
