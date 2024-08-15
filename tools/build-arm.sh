#!/bin/bash

# ------------------------------------
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
# ------------------------------------

repository_root="$(dirname "$(readlink -f "$0")")/.."
echo "Repo root: {$repository_root}"
environments_path="$repository_root/Environments"
echo "Environments path: {$environments_path}"

environments=()
echo "Building ARM templates from bicep files..."

for environment in "$environments_path"/*/; do
    if [ "$environment" != "$environments_path/" ]; then
        environments+=("$environment")
    fi
done

echo "${#environments[@]} environments detected"

# get the full path to the git executable
git="$(command -v git)"

for environment in "${environments[@]}"; do
    echo "  Ensuring: $environment/azuredeploy.json"
    if [ ! -f "$environment/azuredeploy.json" ]; then
        # if the azuredeploy.json file doesn't exist, create it
        touch "$environment/azuredeploy.json"
        # run the git command to add the azuredeploy.json file
        "$git" add "$environment/azuredeploy.json"
    fi
done

# get the full path to the azure cli executable
az="$(command -v az)"

for environment in "${environments[@]}"; do
    echo "  Compiling template: $environment"
    # run the azure cli command to compile the template
    "$az" bicep build --file "$environment/main.bicep" --outfile "$environment/azuredeploy.json"
done

echo "Done"