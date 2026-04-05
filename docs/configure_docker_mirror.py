import json
import os
import platform

def configure_mac_docker_mirror():
    # Mac Docker Desktop daemon.json 默认路径
    daemon_path = os.path.expanduser("~/.docker/daemon.json")
    
    # 目前亲测可用的国内第三方加速源 (由于官方源和阿里个人源经常失效，这里配置多个备用源)
    mirrors = [
        "https://docker.1panel.live",
        "https://hub.rat.dev",
        "https://docker.anyhub.us.kg",
        "https://docker.chenby.cn",
        "https://dockerhub.jobcher.com"
    ]
    
    config = {}
    if os.path.exists(daemon_path):
        try:
            with open(daemon_path, 'r') as f:
                config = json.load(f)
        except Exception as e:
            print(f"Error reading existing daemon.json: {e}")
            
    # 合并或覆盖 registry-mirrors
    existing_mirrors = config.get("registry-mirrors", [])
    for mirror in mirrors:
        if mirror not in existing_mirrors:
            existing_mirrors.append(mirror)
            
    config["registry-mirrors"] = existing_mirrors
    
    # 写回配置
    try:
        os.makedirs(os.path.dirname(daemon_path), exist_ok=True)
        with open(daemon_path, 'w') as f:
            json.dump(config, f, indent=4)
        print(f"✅ Successfully updated {daemon_path} with new registry mirrors.")
        print("Please RESTART your Docker Desktop application to apply the changes.")
    except Exception as e:
        print(f"❌ Failed to write to {daemon_path}: {e}")

if __name__ == "__main__":
    if platform.system() == "Darwin":
        configure_mac_docker_mirror()
    else:
        print("This script is currently designed for macOS Docker Desktop.")
