import os
import requests
import json
import re

# ==========================================
# Figma to Flutter Theme Sync Script
# ==========================================

# 您的 Figma 个人访问令牌 (PAT)
# 注意：为了安全，建议后续将其移入 .env 文件或环境变量中
FIGMA_TOKEN = os.environ.get("FIGMA_TOKEN", "")

# 请将此处替换为您 Figma 文件的 File Key
# 获取方法：Figma 网页版 URL 为 https://www.figma.com/file/【FILE_KEY】/xxx
FILE_KEY = os.environ.get("FIGMA_FILE_KEY", "7q358jLwVdYvH6A0A9xV9A") # 替换为您的真实 File Key

OUTPUT_PATH = "../lib/theme/figma_colors.dart"

def rgba_to_hex(r, g, b, a):
    """将 Figma 的 0-1 RGBA 转换为 Flutter 的 0xAARRGGBB 格式"""
    return f"0x{int(a*255):02X}{int(r*255):02X}{int(g*255):02X}{int(b*255):02X}"

def fetch_figma_styles():
    print(f"正在连接 Figma API 获取文件: {FILE_KEY} ...")
    url = f"https://api.figma.com/v1/files/{FILE_KEY}/styles"
    headers = {"X-Figma-Token": FIGMA_TOKEN}
    
    response = requests.get(url, headers=headers)
    if response.status_code != 200:
        print(f"请求失败: {response.status_code} - {response.text}")
        print("请检查 FILE_KEY 是否正确！")
        return None
    return response.json()

def fetch_figma_file_nodes(node_ids):
    if not node_ids: return None
    url = f"https://api.figma.com/v1/files/{FILE_KEY}/nodes?ids={','.join(node_ids)}"
    headers = {"X-Figma-Token": FIGMA_TOKEN}
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json()
    return None

def generate_flutter_code(colors_map):
    """生成 Flutter Dart 代码"""
    dart_code = """// 自动生成文件：Figma Design Tokens
// 请勿手动修改！每次运行 sync_figma_theme.py 会覆盖此文件。

import 'package:flutter/material.dart';

class FigmaColors {
"""
    for name, hex_val in colors_map.items():
        # 将名称转换为驼峰命名，如 "Primary Container" -> "primaryContainer"
        safe_name = re.sub(r'[^a-zA-Z0-9]', '_', name.lower())
        parts = safe_name.split('_')
        camel_name = parts[0] + ''.join(word.capitalize() for word in parts[1:] if word)
        
        dart_code += f"  static const Color {camel_name} = Color({hex_val});\n"
        
    dart_code += "}\n"
    
    # 确保目录存在
    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        f.write(dart_code)
    
    print(f"✅ 成功生成 Flutter 主题文件: {os.path.abspath(OUTPUT_PATH)}")

def main():
    if FILE_KEY == "请在此处填入您的_FILE_KEY":
        print("⚠️ 错误：请先在脚本中填入您的 Figma FILE_KEY！")
        return

    styles_data = fetch_figma_styles()
    if not styles_data: return
    
    color_styles = [s for s in styles_data.get('meta', {}).get('styles', []) if s['style_type'] == 'FILL']
    
    if not color_styles:
        print("⚠️ 未在 Figma 文件中找到发布的颜色样式 (Color Styles)。请确保设计师在 Figma 中创建并发布了 Color Styles。")
        return

    node_ids = [s['node_id'] for s in color_styles]
    nodes_data = fetch_figma_file_nodes(node_ids)
    
    if not nodes_data: return
    
    colors_map = {}
    for node_id, node_info in nodes_data['nodes'].items():
        document = node_info.get('document', {})
        name = document.get('name', 'Unknown')
        fills = document.get('fills', [])
        if fills and fills[0].get('type') == 'SOLID':
            color = fills[0].get('color', {})
            opacity = fills[0].get('opacity', 1.0)
            hex_val = rgba_to_hex(color.get('r', 0), color.get('g', 0), color.get('b', 0), opacity)
            colors_map[name] = hex_val
            
    generate_flutter_code(colors_map)

if __name__ == "__main__":
    main()
