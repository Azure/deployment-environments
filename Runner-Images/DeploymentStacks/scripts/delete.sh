#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
set -e # exit on error

DIR=$(dirname "$0")
. $DIR/_common.sh

echo "Deleting resource group: $ADE_RESOURCE_GROUP_NAME"

echo "Signing into Azure using MSI"
while true; do
    # managed identity isn't available immediately
    # we need to do retry after a short nap
    az login --identity --only-show-errors --output none && {
        echo "Successfully signed into Azure"
        az account set --subscription $ADE_SUBSCRIPTION_ID
        break
    } || sleep 5
done

echo -e "\n>>> Beginning Deletion ...\n"

az stack group delete --resource-group "$ADE_RESOURCE_GROUP_NAME" \
    --name "$ADE_ENVIRONMENT_NAME" \
    --delete-resources --yes \
    --action-on-unmanage deleteResources


if [ $? -eq 0 ]; then # deployment successfully created
    echo "Successfully Deleted Resources"
else
    echo "Failed to Delete Resources"
    outputDeletionErrors
    exit 1
fi
