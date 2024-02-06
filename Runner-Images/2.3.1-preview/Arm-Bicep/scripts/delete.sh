#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
set -e # exit on error

DIR=$(dirname "$0")
. $DIR/_common.sh
source "/shared/commands.sh"

deploymentName=$(date +"%Y-%m-%d-%H%M%S")
log "Deleting resource group: $ADE_RESOURCE_GROUP_NAME"

log "Signing into Azure using MSI"
while true; do
    # managed identity isn't available immediately
    # we need to do retry after a short nap
    az login --identity --allow-no-subscriptions --only-show-errors --output none 2> $ADE_ERROR_LOG && {
        log "Successfully signed into Azure"
        break
    } || sleep 5
done

log $(az deployment group create --resource-group "$ADE_RESOURCE_GROUP_NAME" \
                                              --name "$deploymentName" \
                                              --no-prompt true --no-wait --mode Complete \
                                              --template-file "$DIR/empty.json" 2>$ADE_ERROR_LOG) ">>> Beginning Deletion ..."

if [ $? -eq 0 ]; then # deployment successfully created
    while true; do

        sleep 1

        ProvisioningState=$(az deployment group show --resource-group "$ADE_RESOURCE_GROUP_NAME" --name "$deploymentName" --query "properties.provisioningState" -o tsv)
        ProvisioningDetails=$(az deployment operation group list --resource-group "$ADE_RESOURCE_GROUP_NAME" --name "$deploymentName")

        trackDeployment "$ProvisioningDetails"

        if [[ "CANCELED|FAILED|SUCCEEDED" == *"${ProvisioningState^^}"* ]]; then

            echo -e "\nDeployment $deploymentName: $ProvisioningState"

            if [[ "CANCELED|FAILED" == *"${ProvisioningState^^}"* ]]; then
                outputDeploymentErrors "$ProvisioningDetails"
                exit 11
            else
                break
            fi
        fi

    done
else
    log "Failed to Delete Resources"
fi
