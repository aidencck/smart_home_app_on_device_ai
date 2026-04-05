import subprocess
import json

# GitHub configuration
OWNER = "aidencck"
REPO = "smart_home_app_on_device_ai"
PROJECT_TITLE = "Luma AI - Sprint 1 (Zero-UI MVP)"

def run_cmd(cmd):
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error running: {cmd}")
        print(result.stderr)
        return None
    return result.stdout.strip()

print("==== 1. Fetching all Sprint-1 Issues ====")
# Fetch issues with label Sprint-1
cmd_fetch_issues = f"gh issue list -R {OWNER}/{REPO} --label 'Sprint-1' --limit 50 --json id,url,title"
issues_json = run_cmd(cmd_fetch_issues)
if not issues_json:
    print("Failed to fetch issues.")
    exit(1)

issues = json.loads(issues_json)
print(f"Found {len(issues)} issues for Sprint-1.")

print("\n==== 2. Creating a new Kanban Project ====")
# Create a new project
cmd_create_project = f'gh project create --owner {OWNER} --title "{PROJECT_TITLE}" --format json'
project_json = run_cmd(cmd_create_project)
if not project_json:
    print("Failed to create project.")
    exit(1)

project_data = json.loads(project_json)
project_id = project_data.get("id")
project_url = project_data.get("url")
print(f"Project created! ID: {project_id}, URL: {project_url}")

print("\n==== 3. Adding Issues to the Project ====")
for issue in issues:
    issue_url = issue["url"]
    issue_title = issue["title"]
    # Add issue to the newly created project
    cmd_add = f'gh project item-add {project_id} --owner {OWNER} --url {issue_url} --format json'
    res = run_cmd(cmd_add)
    if res:
        print(f"Added: {issue_title}")

print("\n==== Sync to Project Complete! ====")
print(f"Please view your Kanban Board here: {project_url}")
