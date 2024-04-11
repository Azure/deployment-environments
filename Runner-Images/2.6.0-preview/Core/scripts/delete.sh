#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# this is a default action implementation which in case of
# system commands only writes some informational output.
# if this action should do something you must create your
# own runner container and replace this file with your
# custom action implementation.

ACTIONFILE=$(basename -- "$0")
ACTIONNAME="${filename%.*}"
DIR=$(dirname "$0")

echo -e "\nThe action ${ACTIONNAME^^} is not implemented yet!"
