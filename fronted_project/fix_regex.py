import os

lib_dir = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib'

def fix_intent_regex():
    p = os.path.join(lib_dir, 'features/agent/fallback_intent_service.dart')
    with open(p, 'r') as f:
        c = f.read()

    # Improve text.contains("冷") to regex
    
    replace_from = """    if (text.contains("冷") ||
        text.contains("温度") ||
        (isContinuing && text.contains("高一点"))) {"""
        
    replace_to = """    final acPattern = RegExp(r'(空调|温度|冷|热|度)');
    final lightPattern = RegExp(r'(灯|亮|暗)');
    final vacuumPattern = RegExp(r'(扫地|打扫|清洁)');
    final outPattern = RegExp(r'(出门|离家|离开)');
    final sleepPattern = RegExp(r'(睡眠|睡觉|晚安)');
    final homePattern = RegExp(r'(回家|回来)');
    final tvPattern = RegExp(r'(电视|电影|剧)');

    if (acPattern.hasMatch(text) || (isContinuing && text.contains("高一点"))) {
      // 提取实体（温度数字）
      final tempMatch = RegExp(r'(\\d{1,2})度').firstMatch(text);
      int temp = 26;
      if (tempMatch != null) {
        temp = int.tryParse(tempMatch.group(1) ?? '26') ?? 26;
      } else if (text.contains("高一点") || text.contains("热")) {
        temp = 28;
      } else if (text.contains("低一点") || text.contains("冷")) {
        temp = 24;
      }"""
      
    c = c.replace(replace_from, replace_to)
    
    c = c.replace("""} else if (text.contains("暗") ||
        text.contains("灯") ||
        (isContinuing && (text.contains("亮一点") || text.contains("关掉它")))) {""", """} else if (lightPattern.hasMatch(text) ||
        (isContinuing && (text.contains("亮一点") || text.contains("关掉它")))) {""")

    c = c.replace("""} else if (text.contains("打扫") || text.contains("扫地")) {""", """} else if (vacuumPattern.hasMatch(text)) {""")
    
    c = c.replace("""} else if (text.contains("出门") || text.contains("离家")) {""", """} else if (outPattern.hasMatch(text)) {""")

    c = c.replace("""} else if (text.contains("睡眠模式")) {""", """} else if (sleepPattern.hasMatch(text)) {""")
    
    c = c.replace("""} else if (text.contains("回家模式")) {""", """} else if (homePattern.hasMatch(text)) {""")

    c = c.replace("""} else if (text.contains("电视") || text.contains("看电影")) {""", """} else if (tvPattern.hasMatch(text)) {""")

    with open(p, 'w') as f:
        f.write(c)

fix_intent_regex()
