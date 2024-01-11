#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
set -e # exit on error

DIR=$(dirname "$0")
source  $DIR/_common.sh
source "/shared/commands.sh"

deploymentName=$(date +"%Y-%m-%d-%H%M%S")
deploymentOutput=""

# format the action parameters as arm parameters
deploymentParameters=$(echo "$ACTION_PARAMETERS" | jq --compact-output '{ "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#", "contentVersion": "1.0.0.0", "parameters": (to_entries | if length == 0 then {} else (map( { (.key): { "value": .value } } ) | add) end) }' )

log "Signing into Azure using MSI"
while true; do
    # managed identity isn't available immediately
    # we need to do retry after a short nap
    az login --identity --allow-no-subscriptions --only-show-errors --output none 2> $ADE_ERROR_LOG && {
        log "Successfully signed into Azure"
        break
    } || sleep 5
done

header "Deploying ARM/Bicep template"
log $(az deployment group create --subscription $ENVIRONMENT_SUBSCRIPTION_ID \
                                                    --resource-group "$ENVIRONMENT_RESOURCE_GROUP_NAME" \
                                                    --name "$deploymentName" \
                                                    --no-prompt true --no-wait \
                                                    --template-file "$ADE_TEMPLATE_FILE" \
                                                    --parameters "$deploymentParameters" \
                                                    2>$ADE_ERROR_LOG) ">>> Beginning Deployment ...\n"

if [ $? -eq 0 ]; then # deployment successfully created
    while true; do

        sleep 1

        ProvisioningState=$(az deployment group show --resource-group "$ENVIRONMENT_RESOURCE_GROUP_NAME" --name "$deploymentName" --query "properties.provisioningState" -o tsv)
        ProvisioningDetails=$(az deployment operation group list --resource-group "$ENVIRONMENT_RESOURCE_GROUP_NAME" --name "$deploymentName")

        trackDeployment "$ProvisioningDetails"

        if [[ "CANCELED|FAILED|SUCCEEDED" == *"${ProvisioningState^^}"* ]]; then

            log "\nDeployment $deploymentName: $ProvisioningState"

            if [[ "CANCELED|FAILED" == *"${ProvisioningState^^}"* ]]; then
                outputDeploymentErrors "$ProvisioningDetails"
                exit 11
            else
                break
            fi
        fi

    done

    header "Generating Outputs"
    deploymentOutput=$(az deployment group show -g "$ENVIRONMENT_RESOURCE_GROUP_NAME" -n "$deploymentName" --query properties.outputs)
    echo "{\"outputs\": $deploymentOutput}" > $ADE_OUTPUTS
    log "Outputs successfully generated"
else
    log "Deployment failed to create."
fi