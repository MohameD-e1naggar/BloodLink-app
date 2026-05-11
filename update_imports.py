import os

replacements = {
    'MyApp.dart': 'my_app.dart',
    'ThemeManager.dart': 'theme_manager.dart',
    'ValidatorManager.dart': 'validator_manager.dart'
}

def update_file(file_path):
    with open(file_path, 'r') as f:
        content = f.read()
    
    new_content = content
    for old, new in replacements.items():
        new_content = new_content.replace(old, new)
    
    if new_content != content:
        with open(file_path, 'w') as f:
            f.write(new_content)
        print(f"Updated {file_path}")

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            update_file(os.path.join(root, file))

for root, dirs, files in os.walk('test'):
    for file in files:
        if file.endswith('.dart'):
            update_file(os.path.join(root, file))
