# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

FROM mcr.microsoft.com/azure-cli:latest
WORKDIR /

ARG IMAGE_VERSION

# Metadata as defined at http://label-schema.org
ARG BUILD_DATE

# Add jq for parsing JSON
RUN apk add jq

COPY entrypoint.sh /entrypoint.sh
COPY shared/* /shared/
COPY scripts/* /scripts/
COPY ade /adecli/ade
COPY appsettings*.json /adecli/

# Convert windows line endings to linux
RUN dos2unix /entrypoint.sh
RUN find /shared/ -type f -iname "*.sh" -exec dos2unix '{}' '+'
RUN find /scripts/ -type f -iname "*.sh" -exec dos2unix '{}' '+'

ENV PATH /adecli:$PATH

RUN chmod +x /entrypoint.sh \
    && chmod +x /adecli/ade \
    && mkdir -p /scripts && find /scripts/ -type f -iname "*.sh" -exec chmod +x {} \;

# Terminate container on stop
STOPSIGNAL SIGTERM

CMD [ "" ]
ENTRYPOINT [ "/entrypoint.sh" ]