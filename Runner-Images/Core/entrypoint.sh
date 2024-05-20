#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

set -e # exit on error
trap 'catch $? $LINENO' EXIT

source "/shared/commands.sh"
declare -g -x -A exitCodeMap=( ["1"]="DeploymentError" ["7"]="InvalidEndpoint" ["8"]="InvalidDevCenterId" ["9"]="CliSetupError" ["10"]="InvalidOperationId" ["11"]="RequestFailed" ["12"]="InvalidCliInput" ["13"]="FileOperationError" ["14"]="EnvironmentStorageExceeded" ["15"]="SecurityError" ["16"]="DeploymentIdentitySignInError" ["17"]="CliUpgradeError" ["99"]="UnknownError")

ADE_STORAGE=/ade/storage
ADE_OUTPUTS=/ade/temp/output.json
ADE_ERROR_LOG=/ade/temp/error.log

mkdir -p "$ADE_STORAGE"
mkdir -p "$(dirname $ADE_OUTPUTS)" && touch "$ADE_OUTPUTS" && touch "$ADE_ERROR_LOG"

# Called on exit.
# Handles failures, updating storage, logs, etc.
# TODO: When calling trap on EXIT signal, bash resets $LINENO to 0 before executing catch() function. Will either need to create a work-around or not utilize line number.
catch() {
    # Enable glob bash options, use a glob to list all files in storage, then count the number of them.
    if (shopt -s nullglob dotglob; f=($ADE_STORAGE/*); ((${#f[@]}))); then
        verbose "Uploading environment state to $ADE_STORAGE"
        ade files upload --folder-path $ADE_STORAGE
    fi

    # Send outputs if we've written any
    if [ -s $ADE_OUTPUTS ]; then
        verbose "Uploading outputs"
        ade outputs upload --file $ADE_OUTPUTS
    fi

    if [ "$1" != "0" ]; then
        # we trapped an error - set up reporting output to environment object, log it as an error, and clear the error log
        exitCode=$( echo "${exitCodeMap[$1]}")

        if [ -s $ADE_ERROR_LOG ]; then
            additionalErrorDetails=$(cat $ADE_ERROR_LOG)
            > $ADE_ERROR_LOG
        fi

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

verbose "Checking for ADE CLI updates"
upgradeCli

verbose "Initializing runner"
eval "$(ade init)"

verbose "Downloading environment state to $ADE_STORAGE"
# Download data, ignoring if it doesn't exist
ade files download --file-name storage.zip --folder-path $ADE_STORAGE --unzip || true

verbose "Selecting catalog directory: $(dirname $ADE_TEMPLATE_FILE)"
cd $(dirname $ADE_TEMPLATE_FILE)

# the script to execute is defined by the following options
# (the first option matching an executable script file wins)
#
# Option 1: a script file following the pattern [ADE_OPERATION_NAME].sh exists in the
#           current working directory (environment definition directory)
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
    verbose "Executing script ($script)"

    # Execute the script, but ensure we still save stderr to an error log file.
    ade execute --operation $ADE_OPERATION_NAME --command "$script" 2> >(tee -a $ADE_ERROR_LOG)
elif [[ -f "$script" ]]; then
    error "Script '$script' is not marked as executable" && exit 1
else
    error "Script '$script' does not exist" && exit 1
fi