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

log "$(terraform plan -no-color -compact-warnings -refresh=true -lock=true -state=$EnvironmentState -out=$EnvironmentPlan -var-file="$EnvironmentVars" 2> $ADE_ERROR_LOG)"

header "Applying Terraform Plan"
log "$(terraform apply -no-color -compact-warnings -auto-approve -lock=true -state=$EnvironmentState $EnvironmentPlan 2> $ADE_ERROR_LOG)"

# Outputs must be written to a specific file location.
# ADE expects data types array, boolean, number, object and string.
# Terraform outputs list, bool, number, map, set, string and null
# In addition, Terraform has type constraints, which allow for specifying the types of nested properties.
header "Generating outputs for ADE"
tfout="$(terraform output -state=$EnvironmentState -json 2> $ADE_ERROR_LOG)"

# Convert Terraform output format to our internal format.
tfout=$(jq 'walk(if type == "object" then 
            if .type == "bool" then .type = "boolean" 
            elif .type == "list" then .type = "array" 
            elif .type == "map" then .type = "object" 
            elif .type == "set" then .type = "array" 
            elif (.type | type) == "array" then 
                if .type[0] == "tuple" then .type = "array" 
                elif .type[0] == "object" then .type = "object" 
                elif .type[0] == "set" then .type = "array" 
                else . 
                end 
            else . 
            end 
        else . 
        end)' <<< "$tfout")

echo "{\"outputs\": $tfout}" > $ADE_OUTPUTS
log "Outputs successfully generated for ADE"