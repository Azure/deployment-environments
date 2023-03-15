# ------------------------------------
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
# ------------------------------------

import os
import shutil
import subprocess

from pathlib import Path

repository_root = Path(__file__).resolve().parent.parent
environments_path = repository_root / 'Environments'

environments = []

print('Building ARM templates from bicep files...')
# walk the Environments directory and find all the child directories
for dirpath, dirnames, files in os.walk(environments_path):
    # os.walk includes the root directory (i.e. repo/Environments) so we need to skip it
    if not environments_path.samefile(dirpath) and Path(dirpath).parent.samefile(environments_path):
        environments.append(Path(dirpath))
        # image_names.append(Path(dirpath).name)

# get the full path to the git executable
git = shutil.which('git')

for environment in environments:
    print(f'  Ensuring: {environment}/azuredeploy.json')
    if not (environment / 'azuredeploy.json').exists():
        # if the azuredeploy.json file doesn't exist, create it
        (environment / 'azuredeploy.json').touch()
        # run the git command to add the azuredeploy.json file
        subprocess.run([git, 'add', environment / 'azuredeploy.json'])

# get the full path to the azure cli executable
az = shutil.which('az')

for environment in environments:
    print(f'  Compiling template: {environment}')
    # run the azure cli command to compile the template
    subprocess.run([az, 'bicep', 'build', '--file', environment / 'main.bicep', '--outfile', environment / 'azuredeploy.json'])

print('Done')
