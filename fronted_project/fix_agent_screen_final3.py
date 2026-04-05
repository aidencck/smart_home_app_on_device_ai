import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def fix_agent_screen_notify():
    p = os.path.join(lib_dir, 'presentation/pages/agent_screen.dart')
    with open(p, 'r') as f:
        c = f.read()

    # invalid_use_of_visible_for_testing_member
    # invalid_use_of_protected_member
    # It says we use `notifyListeners` in agent_screen.dart
    # Wait, notifyListeners is on ChangeNotifier.
    # Lines 74 and 85: ref.read(agentManagerProvider).notifyListeners() ?
    c = c.replace("ref.read(agentManagerProvider).notifyListeners();", "")

    # Undefined name 'deviceManager' at 637
    c = c.replace("deviceManager.getDeviceByName", "ref.read(deviceManagerProvider).getDeviceByName")

    # TransitionBuilder
    # c = c.replace("transitionBuilder: (child, animation) {", "transitionBuilder: (Widget child, Animation<double> animation) {")
    # Actually AnimatedSwitcher signature is `Widget Function(Widget child, Animation<double> animation)`
    c = c.replace("transitionBuilder: (Widget child, Animation<double> animation) {", "transitionBuilder: (Widget child, Animation<double> animation) {")
    # Wait let's just do a blanket regex to be safe
    import re
    c = re.sub(r"transitionBuilder:\s*\([^\)]+\)\s*\{", "transitionBuilder: (Widget child, Animation<double> animation) {", c)
    c = c.replace("opacity: const AlwaysStoppedAnimation(1)", "opacity: animation")

    with open(p, 'w') as f:
        f.write(c)

fix_agent_screen_notify()
