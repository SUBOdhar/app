import os
import subprocess

original_directory = os.getcwd()
os.chdir('svp')
# Command to build the Flutter APK
build_command = r'flutter build apk --release'

# Execute the build command and capture the output
result = subprocess.run(build_command, shell=True,
                        capture_output=True, text=True)

# Print the result for debugging
print("Build command output:")
print(result.stdout)
print(result.stderr)

# Check if the build was successful
if result.returncode == 0:
    print("Build succeeded.")
    # Run the subsequent scripts
    os.chdir(original_directory)
    subprocess.run('python release_github.py', shell=True)
    subprocess.run('python auth.py', shell=True)
else:
    print("Build failed. Skipping subsequent steps.")
