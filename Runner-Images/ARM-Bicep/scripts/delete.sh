#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
set -e # exit on error

DIR=$(dirname "$0")
. $DIR/_common.sh

deploymentName=$(date +"%Y-%m-%d-%H%M%S")
echo "Deleting resource group: $ADE_RESOURCE_GROUP_NAME"

echo "Signing into Azure using MSI"
while true; do
    # managed identity isn't available immediately
    # we need to do retry after a short nap
    az login --identity --allow-no-subscriptions --only-show-errors --output none && {
        echo "Successfully signed into Azure"
        break
    } || sleep 5
done

echo -e "\n>>> Beginning Deletion...\n"

if [[ $(az group exists --subscription $ADE_SUBSCRIPTION_ID --name "$ADE_RESOURCE_GROUP_NAME") == 'false' ]]; then
    echo "Resource group $ADE_RESOURCE_GROUP_NAME does not exist, resources successfully cleaned up"
    exit 0
fi

az deployment group create --subscription $ADE_SUBSCRIPTION_ID \
    --resource-group "$ADE_RESOURCE_GROUP_NAME" \
    --name "$deploymentName" \
    --no-prompt true --no-wait --mode Complete \
    --only-show-errors \
    --template-file "$DIR/empty.json"

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
    echo "Failed to Delete Resources"
fi
