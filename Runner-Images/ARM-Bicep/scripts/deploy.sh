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

# We can resolve linked templates with
# relativePaths before submitting the deployment to ARM by:
#
#   1. Use `bicep decompile` to transpile the ARM template into
#      bicep modules. During this process bicep will resolve the linked
#      templates locally and convert them each into bicep modules.
#
#   2. Then run `bicep build` to transpile those bicep modules back
#      into ARM. This will output a new, single ARM template with the
#      linked templates embedded as nested templates
if [[ $ADE_TEMPLATE_FILE == *.json ]]; then

    hasRelativePath=$( cat $ADE_TEMPLATE_FILE | jq '[.. | objects | select(has("templateLink") and (.templateLink | has("relativePath")))] | any' )

    if [ "$hasRelativePath" = "true" ]; then
        echo "Resolving linked ARM templates"

        bicepTemplate="${ADE_TEMPLATE_FILE/.json/.bicep}"
        generatedTemplate="${ADE_TEMPLATE_FILE/.json/.generated.json}"

        az bicep decompile --file "$ADE_TEMPLATE_FILE"
        az bicep build --file "$bicepTemplate" --outfile "$generatedTemplate"

        # Correctly reassign ADE_TEMPLATE_FILE without the $ prefix during assignment
        ADE_TEMPLATE_FILE="$generatedTemplate"
    else
        echo "Not linked template"
    fi
fi


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
    sleep 20 # wait a bit to ensure deployment is created and found by tracking commands
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
        echo "No outputs found for deployment"
    else
        setOutputs "$deploymentOutput"
        echo "Outputs successfully generated for ADE"
    fi
else
    echo "Deployment failed to create."
fi