import os

path = '/Users/aiden/Projects/macinit/smart_home_projects/fronted_project/lib/presentation/app.dart'
with open(path, 'r') as f:
    content = f.read()

content = content.replace("home: const HomeShell(),", "home: const HomeShell(),") # Wait let me just use regex or replace
content = content.replace("const HomeShell()", "HomeShell()")

with open(path, 'w') as f:
    f.write(content)
