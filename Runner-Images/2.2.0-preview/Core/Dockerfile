# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

FROM mcr.microsoft.com/azure-cli:latest
WORKDIR /

ARG IMAGE_VERSION

# Metadata as defined at http://label-schema.org
ARG BUILD_DATE

# Add jq for parsing JSON
RUN apk add jq

COPY entrypoint.d/* /entrypoint.d/
COPY entrypoint.sh /entrypoint.sh
COPY shared/* /shared/
COPY actions.d/* /actions.d/
COPY ade /adecli/ade
COPY appsettings*.json /adecli/

# Convert windows line endings to linux
RUN dos2unix /entrypoint.sh
RUN find /entrypoint.d/ -type f -iname "*.sh" -exec dos2unix '{}' '+'
RUN find /shared/ -type f -iname "*.sh" -exec dos2unix '{}' '+'
RUN find /actions.d/ -type f -iname "*.sh" -exec dos2unix '{}' '+'

ENV PATH /adecli:$PATH

RUN chmod +x /entrypoint.sh \
    && chmod +x /adecli/ade \
    && mkdir -p /entrypoint.d && find /entrypoint.d/ -type f -iname "*.sh" -exec chmod +x {} \; \
    && mkdir -p /actions.d && find /actions.d/ -type f -iname "*.sh" -exec chmod +x {} \;

# Terminate container on stop
STOPSIGNAL SIGTERM

CMD [ "" ]
ENTRYPOINT [ "/entrypoint.sh" ]