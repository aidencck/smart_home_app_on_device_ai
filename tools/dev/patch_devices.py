import re

path = "/Users/aiden/Projects/macinit/smarthome APP/smart_home_app/lib/features/device/presentation/devices_page.dart"
with open(path, "r") as f:
    content = f.read()

old_str = """  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(deviceItemStateProvider(deviceId));
    
    final theme = Theme.of(context);
    
    return RepaintBoundary("""

new_str = """  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(deviceItemStateProvider(deviceId));
    if (d == null) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    
    return RepaintBoundary("""

content = content.replace(old_str, new_str)

with open(path, "w") as f:
    f.write(content)
