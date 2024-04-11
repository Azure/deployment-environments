#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
set -e # exit on error

DIR=$(dirname "$0")
source  $DIR/_common.sh

deploymentName=$(date +"%Y-%m-%d-%H%M%S")
deploymentOutput=""

# format the parameters as arm parameters
deploymentParameters=$(echo "$ADE_OPERATION_PARAMETERS" | jq --compact-output '{ "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#", "contentVersion": "1.0.0.0", "parameters": (to_entries | if length == 0 then {} else (map( { (.key): { "value": .value } } ) | add) end) }' )

echo "Signing into Azure using MSI"
while true; do
    # managed identity isn't available immediately
    # we need to do retry after a short nap
    az login --identity --allow-no-subscriptions --only-show-errors --output none && {
        echo "Successfully signed into Azure"
        break
    } || sleep 5
done

echo -e "\n>>>Deploying ARM/Bicep template...\n"
az deployment group create --subscription $ADE_SUBSCRIPTION_ID \
    --resource-group "$ADE_RESOURCE_GROUP_NAME" \
    --name "$deploymentName" \
    --no-prompt true --no-wait \
    --template-file "$ADE_TEMPLATE_FILE" \
    --parameters "$deploymentParameters" \
    --only-show-errors

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
    
    echo -e "\n>>> Generating outputs for ADE...\n"

    deploymentOutput=$(az deployment group show -g "$ADE_RESOURCE_GROUP_NAME" -n "$deploymentName" --query properties.outputs)
    if [ -z "$deploymentOutput" ]; then
        deploymentOutput="{}"
    fi
    echo "{\"outputs\": $deploymentOutput}" > $ADE_OUTPUTS
    echo "Outputs successfully generated for ADE"
else
    echo "Deployment failed to create."
fi