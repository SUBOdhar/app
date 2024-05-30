import re
import subprocess
import sys
import json


def new_release():
    # Execute the command and capture the output
    result = subprocess.run(release_command, shell=True,
                            capture_output=True, text=True)
    # Write the result output to a file
    with open('url', 'w') as file_url:
        file_url.write(result.stdout)


def exit_program():
    print("Exiting program....")
    sys.exit(0)


# Path to your file, using a raw string to handle backslashes in Windows paths
file_path = r'svp\pubspec.yaml'

# Compile a regex pattern to find "version:" followed by a version number format (including decimal points)
pattern = re.compile(r"version:\s*([\d.]+)")

# Read the file content
with open(file_path, 'r') as file:
    content = file.read()

# Search for the pattern in the file content
match = pattern.search(content)

if match:
    version_number = match.group(1)
    print(version_number)
else:
    print("No match found.")
    version_number = "unknown"  # Default version number if no match is found
    exit_program()

check_release_command = f'gh release view v{version_number} --json url'
release_info = subprocess.run(
    check_release_command, shell=True, capture_output=True, text=True)
if release_info.returncode == 0:
    release_data = json.loads(release_info.stdout)
    if 'url' in release_data:
        existing_url = release_data['url']
        print('already released')
        print(existing_url)

    else:
        existing_url = None
else:
    print("Error occurred while checking the release.")
    exit_program()

# Prepare the GitHub release command
release_command = f'gh release create v{
    version_number} svp\\build\\app\\outputs\\flutter-apk\\app-release.apk --generate-notes'

if not existing_url:
    new_release()

# Write the result output to a file
with open('url', 'w') as file_url:
    file_url.write(existing_url)

# Write the version number to a file
with open('version', 'w') as version_file:
    version_file.write(version_number)

# Optional: Print the result output for debugging
