import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def fix_agent_screen_more_errors():
    p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')
    with open(p, 'r') as f:
        c = f.read()

    # The transitionBuilder issue
    # The original was probably `transitionBuilder: (child) {` but now it needs `(child, animation) {`
    # Let's just fix it manually using regex or string replace
    c = c.replace(
        "transitionBuilder: (child) {",
        "transitionBuilder: (child, animation) {"
    )

    # 637, 641: deviceManager.getDeviceByName -> ref.read(deviceManagerProvider).getDeviceByName
    # If they are still there
    c = c.replace("deviceManager.getDeviceByName", "ref.read(deviceManagerProvider).getDeviceByName")

    with open(p, 'w') as f:
        f.write(c)

fix_agent_screen_more_errors()
