#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

set -e # exit on error
trap 'catch $? $LINENO' EXIT

source "/shared/commands.sh"
declare -g -x -A exitCodeMap=( ["1"]="DeploymentError" ["7"]="InvalidEndpoint" ["8"]="InvalidDevCenterId" ["9"]="CliSetupError" ["10"]="InvalidOperationId" ["11"]="RequestFailed" ["12"]="InvalidCliInput" ["13"]="FileOperationError" ["99"]="UnknownError")

# Called on exit.
# Handles failures, updating storage, logs, etc.
# TODO: When calling trap on EXIT signal, bash resets $LINENO to 0 before executing catch() function. Will either need to create a work-around or not utilize line number.
catch() {
    # Enable glob bash options, use a glob to list all files in storage, then count the number of them.
    if (shopt -s nullglob dotglob; f=($ADE_STORAGE/*); ((${#f[@]}))); then
        echo "Uploading environment state to $ADE_STORAGE"
        ade files upload --folder-path $ADE_STORAGE
    fi

    # Send outputs if we've written any
    if [ -s $ADE_OUTPUTS ]; then
        echo "Uploading outputs"
        ade outputs upload --file $ADE_OUTPUTS
    fi

    if [ "$1" != "0" ]; then
        # we trapped an error - set up reporting output to environment object, log it as an error, and clear the error log
        exitCode=$( echo "${exitCodeMap[$1]}")
        additionalErrorDetails=$(cat $ADE_ERROR_LOG)
        > $ADE_ERROR_LOG
        if [ -z "$exitCode" ]; then
            exitCode="UnknownError"
            error "Operation failed with exit code $exitCode, code value $1 !!!"
        else
            error "Operation failed with exit code $exitCode !!!"
        fi
        ade operation-result --code $exitCode --message "Operation failed with exit code $exitCode ! Additional Error Details: $additionalErrorDetails"
    else
        log "Operation completed successfully!"
    fi

}

# New hard-coded variables
export ADE_TEMP=/ade/temp
export ADE_OPERATION_LOG=$ADE_TEMP/operation.log
export ADE_ERROR_LOG=$ADE_TEMP/error.log
export ADE_OUTPUTS=$ADE_TEMP/output.json
export ADE_STORAGE=/ade/storage

mkdir -p $ADE_TEMP
touch $ADE_OPERATION_LOG
touch $ADE_ERROR_LOG

# TODO: consider using the CLI to set these variables. Would make versioning easier post-custom runner.
# TODO: handle errors returned from RMS API.
# TODO: review all environment variable names.
# TODO: upload outputs.

echo "Fetching definition"
definition=$(ade definitions list)

echo "Identifying managed identity"
export ADE_CLIENT_ID=$(ade info client-id)
export ADE_TENANT_ID=$(ade info tenant-id)

echo "Setting up catalog folder structure"
contentSourcePath=$(echo $definition | jq -r ".ContentSourcePath")
templatePath=$(echo $definition | jq -r ".TemplatePath")
catalogRoot=/ade/repository
export ADE_MANIFEST_FOLDER="$catalogRoot/$contentSourcePath"
export ADE_TEMPLATE_FILE="$catalogRoot/$templatePath"
mkdir -p $ADE_MANIFEST_FOLDER

echo "Fetching environment"
environment=$(ade environment)
export ADE_OPERATION_PARAMETERS=$(echo $environment | jq ".Parameters")
export ADE_ENVIRONMENT_TYPE=$(echo $environment | jq -r ".EnvironmentType")
export ADE_ENVIRONMENT_NAME=$(echo $environment | jq -r ".Name")
export ADE_ENVIRONMENT_LOCATION=$(echo $environment | jq -r ".Location")
environmentRgId=$(echo $environment | jq -r ".ResourceGroupId")

export ADE_RESOURCE_GROUP_NAME=$(echo $environmentRgId | cut -d"/" -f5)
export ADE_SUBSCRIPTION_ID=$(echo $environmentRgId | cut -d"/" -f3)

echo "Downloading environment definition to $ADE_MANIFEST_FOLDER"
ade definitions download --folder-path $ADE_MANIFEST_FOLDER

echo "Downloading environment state to $ADE_STORAGE"
# Download data, ignoring if it doesn't exist
#TODO: Would like to only run this for terraform actions, would need to pass in runner type variable to do so.
ade files download --file-name storage.zip --folder-path $ADE_STORAGE --unzip || true

echo "Selecting catalog directory: $(dirname $ADE_TEMPLATE_FILE)"
cd $(dirname $ADE_TEMPLATE_FILE)

# the script to execute is defined by the following options
# (the first option matching an executable script file wins)
#
# Option 1: a script file following the pattern [ADE_OPERATION_NAME].sh exists in the
#           current working directory (catalog item directory)
#
# Option 2: a script file following the pattern [ADE_OPERATION_NAME].sh exists in the
#           /scripts directory (operation script directory)
if [[ $ADE_ENABLE_CUSTOM_DEPLOY = true ]]; then
    verbose "Using custom built-in operation"
    script="$(find $PWD -maxdepth 1 -iname "$ADE_OPERATION_NAME.sh")"
fi
if [[ -z "$script" ]]; then
    script="$(find /scripts -maxdepth 1 -iname "$ADE_OPERATION_NAME.sh")"
fi
if [[ -z "$script" ]]; then
    error "Operation $ADE_OPERATION_NAME is not supported." && exit 1
fi

if [[ -f "$script" && -x "$script" ]]; then
    # lets execute the task script - isolate execution in sub shell
    verbose "Executing script ($script)"; ( exec "$script"; exit $? ) || exit $?
elif [[ -f "$script" ]]; then
    error "Script '$script' is not marked as executable" && exit 1
else
    error "Script '$script' does not exist" && exit 1
fi