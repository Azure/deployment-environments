#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

set -e # exit on error

source "/shared/commands.sh"

EnvironmentState="$ADE_STORAGE/environment.tfstate"
EnvironmentPlan="$ADE_TEMP/environment.tfplan"
EnvironmentVars="$ADE_TEMP/environment.tfvars.json"

echo "$ADE_OPERATION_PARAMETERS" > $EnvironmentVars

# Set up Terraform AzureRM managed identity.
export ARM_USE_MSI=true
export ARM_CLIENT_ID=$ADE_CLIENT_ID
export ARM_TENANT_ID=$ADE_TENANT_ID
export ARM_SUBSCRIPTION_ID=$ADE_SUBSCRIPTION_ID

if ! test -f $EnvironmentState; then
    echo "No state file present. Delete succeeded."
    exit 0
fi

header "Terraform Info"
log "$(terraform -version 2> $ADE_ERROR_LOG)"

header "Initializing Terraform"
log "$(terraform init -no-color 2> $ADE_ERROR_LOG)"

header "Creating Terraform Plan"
export TF_VAR_resource_group_name=$ADE_RESOURCE_GROUP_NAME
export TF_VAR_ade_env_name=$ADE_ENVIRONMENT_NAME
export TF_VAR_env_name=$ADE_ENVIRONMENT_NAME
export TF_VAR_ade_subscription=$ADE_SUBSCRIPTION_ID
export TF_VAR_ade_location=$ADE_ENVIRONMENT_LOCATION
export TF_VAR_ade_environment_type=$ADE_ENVIRONMENT_TYPE
log "$(terraform plan -no-color -compact-warnings -destroy -refresh=true -lock=true -state=$EnvironmentState -out=$EnvironmentPlan -var-file="$EnvironmentVars" 2> $ADE_ERROR_LOG)"

header "Applying Terraform Plan"
log "$(terraform apply -no-color -compact-warnings -auto-approve -lock=true -state=$EnvironmentState $EnvironmentPlan 2> $ADE_ERROR_LOG)"
