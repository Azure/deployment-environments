# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

ARG BASE_IMAGE=mcr.microsoft.com/deployment-environments/runners/core
ARG IMAGE_VERSION=latest

FROM ${BASE_IMAGE}:${IMAGE_VERSION}
WORKDIR /

ARG IMAGE_VERSION

# Metadata as defined at http://label-schema.org
ARG BUILD_DATE

# install bicep
RUN az bicep install

# Grab all .sh files from actions.d, copy to
# root actions.d, replace line-endings and make them all executable
COPY actions.d/* /actions.d/
RUN find /actions.d/ -type f -iname "*.sh" -exec dos2unix '{}' '+'
RUN find /actions.d/ -type f -iname "*.sh" -exec chmod +x {} \;
