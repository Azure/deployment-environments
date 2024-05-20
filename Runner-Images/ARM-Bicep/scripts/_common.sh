#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

trackDeployment() {

    trace="$( echo "$1" | jq --raw-output '.[] | [.operationId, .properties.timestamp, .properties.provisioningOperation, .properties.provisioningState, .properties.targetResource.id // ""] | @tsv' )"

    echo "$trace" | while read -r line; do
        if [[ ! -z "$line" ]]; then

            operationId="$( echo "$line" | cut -f 1 )"
            operationTimestamp="$( echo "$line" | cut -f 2 | cut -d . -f 1 | sed 's/T/ /g' )"
            operationType="$( echo "$line" | cut -f 3 )"
            operationState="$( echo "$line" | cut -f 4 )"
            operationTarget="$( echo "$line" | cut -f 5 )"
            operationHash="$( echo "$operationId|$operationState" | md5sum | cut -d ' ' -f 1 )"

            if ! grep -q "$operationHash" /tmp/hashes 2>/dev/null ; then

                echo -e "\n$operationTimestamp\t$operationId - $operationType ($operationState)"

                if [[ ! -z "$operationTarget" ]]; then
                    echo -e "\t\t\t$operationTarget"
                fi

                echo "$operationHash" >> /tmp/hashes

            fi
        fi
    done
}

outputDeploymentErrors() {
    echo -e "Deployment failed with the following errors:\n" 1>&2
    readarray errors -t <<< $(echo $1 | jq -c '.[] | .properties | select(has("statusMessage") and (.statusMessage | has("error")))')
    echo -e "Number of errors: ${#errors[@]}\n" 1>&2
    for item in "${errors[@]}"; do
        echo -e "Target Resource ID: $( echo $item | jq '. | .targetResource.id' )\nError Code: $( echo $item | jq '.statusMessage.error.code' )\nError Message: $( echo $item | jq '.statusMessage.error.message' )\n" 1>&2
        readarray errorDetails -t <<< $(echo $item | jq -c '.statusMessage.error.details')
        if [ "${errorDetails[0]}" != null ]; then
            for detail in "${errorDetails[@]}"; do
                echo -e "Error Detail Code: $( echo $detail | jq '.[] | .code')\nError Detail Message: $(echo $detail | jq '.[] | .message')\n" 1>&2
            done
        fi
    done
}

setOutputs() {
    outputs=$1
    outputs=$(jq 'walk(if type == "object" then
                    if .type == "Bool" then .type = "boolean"
                    elif .type == "Int" then .type = "number"
                    else . 
                    end 
                 else . 
                 end)' <<< "$outputs")
    echo "{\"outputs\": $outputs}" > $ADE_OUTPUTS
}
