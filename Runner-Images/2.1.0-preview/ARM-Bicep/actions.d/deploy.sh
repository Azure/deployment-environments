#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

DIR=$(dirname "$0")
. $DIR/_common.sh

trace() {
    echo -e "\n>>> $@ ...\n"
}

deploymentName=$(date +"%Y-%m-%d-%H%M%S")
deploymentOutput=""

# format the action parameters as arm parameters
deploymentParameters=$(echo "$ACTION_PARAMETERS" | jq --compact-output '{ "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#", "contentVersion": "1.0.0.0", "parameters": (to_entries | if length == 0 then {} else (map( { (.key): { "value": .value } } ) | add) end) }' )

trace "Deploying ARM template"
deploymentOutput=$(az deployment group create --subscription $ENVIRONMENT_SUBSCRIPTION_ID \
                                                    --resource-group "$ENVIRONMENT_RESOURCE_GROUP_NAME" \
                                                    --name "$deploymentName" \
                                                    --no-prompt true --no-wait \
                                                    --template-file "$ADE_TEMPLATE_FILE" \
                                                    --parameters "$deploymentParameters" \
                                                    2>&1)

if [ $? -eq 0 ]; then # deployment successfully created
    while true; do

        sleep 1

        ProvisioningState=$(az deployment group show --resource-group "$ENVIRONMENT_RESOURCE_GROUP_NAME" --name "$deploymentName" --query "properties.provisioningState" -o tsv)
        ProvisioningDetails=$(az deployment operation group list --resource-group "$ENVIRONMENT_RESOURCE_GROUP_NAME" --name "$deploymentName")

        trackDeployment "$ProvisioningDetails"

        if [[ "CANCELED|FAILED|SUCCEEDED" == *"${ProvisioningState^^}"* ]]; then

            echo -e "\nDeployment $deploymentName: $ProvisioningState"

            if [[ "CANCELED|FAILED" == *"${ProvisioningState^^}"* ]]; then
                outputDeploymentErrors "$ProvisioningDetails"
                exit 1
            else
                break
            fi
        fi

    done
else
    echo "Deployment failed to create."
fi

# trim spaces from output to avoid issues in the following (generic) error section
deploymentOutput=$(echo "$deploymentOutput" | sed -e 's/^[[:space:]]*//')
if [ ! -z "$deploymentOutput" ]; then

    if [ $(echo "$deploymentOutput" | jq empty > /dev/null 2>&1; echo $?) -eq 0 ]; then
        # the component deployment output was identified as JSON - lets extract some error information to return a more meaningful output
        deploymentOutput="$( echo $deploymentOutput | jq --raw-output '.. | .message? | select(. != null) | "Error: \(.)\n"' | sed 's/\\n/\n/g'  )"
    fi

    if [[ $deploymentOutput == *"ERROR"* || $deploymentOutput == *"Error"* || "CANCELED|FAILED" == *"${ProvisioningState^^}"* ]]; then
        echo "$deploymentOutput" && exit 1
    fi

fi