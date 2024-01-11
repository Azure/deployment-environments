#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

set -e # exit on error
trap 'catch $? $LINENO' EXIT

source "/shared/commands.sh"

# Called on exit.
# Handles failures, updating storage, logs, etc.
catch() {
    if [ "$1" != "0" ]; then
        # we trapped an error - write some reporting output
        error "Exit code $1 was returned from line #$2 !!!"
    fi

    # Enable glob bash options, use a glob to list all files in storage, then count the number of them.
    if (shopt -s nullglob dotglob; f=($ADE_STORAGE/*); ((${#f[@]}))); then
        echo "Uploading environment state to $ADE_STORAGE"
        ade files upload --folder-path $ADE_STORAGE
    fi

    # Send logs if we've written any
    if [ -s $ADE_OPERATION_LOG ]; then
        echo "Uploading logs"
        logContent=$(cat $ADE_OPERATION_LOG)
        ade log --content "$logContent"
    fi

    # Send outputs if we've written any
    if [ -s $ADE_OUTPUTS ]; then
        echo "Uploading outputs"
        ade outputs upload --file $ADE_OUTPUTS
    fi
}

# New hard-coded variables
export ADE_TEMP=/ade/temp
export ADE_OPERATION_LOG=$ADE_TEMP/operation.log
export ADE_OUTPUTS=$ADE_TEMP/output.json
export ADE_STORAGE=/ade/storage
export ARM_USE_MSI=true

mkdir -p $ADE_TEMP
touch $ADE_OPERATION_LOG

# TODO: consider using the CLI to set these variables. Would make versioning easier post-custom runner.
# TODO: handle errors returned from RMS API.
# TODO: review all environment variable names.
# TODO: upload outputs.

echo "Fetching definition"
definition=$(ade definitions list)

echo "Identifying managed identity"
export ARM_CLIENT_ID=$(ade info client-id)
export ARM_TENANT_ID=$(ade info tenant-id)

echo "Setting up catalog folder structure"
contentSourcePath=$(echo $definition | jq -r ".ContentSourcePath")
templatePath=$(echo $definition | jq -r ".TemplatePath")
catalogRoot=/ade/repository
export ADE_MANIFEST_FOLDER="$catalogRoot/$contentSourcePath"
export ADE_TEMPLATE_FILE="$catalogRoot/$templatePath"
mkdir -p $ADE_MANIFEST_FOLDER

echo "Fetching environment"
environment=$(ade environment)
export ACTION_PARAMETERS=$(echo $environment | jq ".Parameters")
export ADE_ENVIRONMENT_TYPE=$(echo $environment | jq -r ".EnvironmentType")
export ADE_ENVIRONMENT_NAME=$(echo $environment | jq -r ".Name")
export ADE_ENVIRONMENT_LOCATION=$(echo $environment | jq -r ".Location")
environmentRgId=$(echo $environment | jq -r ".ResourceGroupId")

export ENVIRONMENT_RESOURCE_GROUP_NAME=$(echo $environmentRgId | cut -d"/" -f5)
export ENVIRONMENT_SUBSCRIPTION_ID=$(echo $environmentRgId | cut -d"/" -f3)
export ARM_SUBSCRIPTION_ID=$ENVIRONMENT_SUBSCRIPTION_ID

echo "Downloading environment definition to $ADE_MANIFEST_FOLDER"
ade definitions download --folder-path $ADE_MANIFEST_FOLDER

echo "Downloading environment state to $ADE_STORAGE"
# Download data, ignoring if it doesn't exist
ade files download --file-name storage.zip --folder-path $ADE_STORAGE --unzip true || true

echo "Selecting catalog directory: $(dirname $ADE_TEMPLATE_FILE)"
cd $(dirname $ADE_TEMPLATE_FILE)

# the script to execute is defined by the following options
# (the first option matching an executable script file wins)
#
# Option 1: a script path is provided as docker CMD command
#
# Option 2: a script file following the pattern [ACTION_NAME].sh exists in the
#           current working directory (catalog item directory)
#
# Option 3: a script file following the pattern [ACTION_NAME].sh exists in the
#           /actions.d directory (actions script directory)

script="$@"

if [[ -z "$script" ]]; then
    if [[ $ADE_ENABLE_CUSTOM_DEPLOY = true ]]; then
        trace "Using custom built-in action"
        script="$(find $PWD -maxdepth 1 -iname "$ACTION_NAME.sh")"
    fi
    if [[ -z "$script" ]]; then
        script="$(find /actions.d -maxdepth 1 -iname "$ACTION_NAME.sh")"
    fi
    if [[ -z "$script" ]]; then
        error "Action $ACTION_NAME is not supported." && exit 1
    fi
fi

if [[ -f "$script" && -x "$script" ]]; then
    # lets execute the task script - isolate execution in sub shell
    trace "Executing script ($script)"; ( exec "$script"; exit $? ) || exit $?
elif [[ -f "$script" ]]; then
    error "Script '$script' is not marked as executable" && exit 1
else
    error "Script '$script' does not exist" && exit 1
fi