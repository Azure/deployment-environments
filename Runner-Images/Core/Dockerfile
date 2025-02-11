# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

FROM mcr.microsoft.com/azure-cli:2.67.0
WORKDIR /

ARG IMAGE_VERSION

# Metadata as defined at http://label-schema.org
ARG BUILD_DATE

# Install jq, dos2unix, libicu, wget & unzip
RUN tdnf install -y jq
RUN tdnf install -y dos2unix
RUN tdnf install -y libicu
RUN tdnf install -y wget
RUN tdnf install -y unzip

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