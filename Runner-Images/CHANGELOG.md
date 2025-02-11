# Change Log

## Version 1.1.0
Updated Azure CLI base image moving from [Alpine to Mariner Linux](https://techcommunity.microsoft.com/blog/azuretoolsblog/azure-cli-docker-container-base-linux-image-is-now-azure-linux/4236248). Has the potential to break new builds. Namely, commands such as `apk add` will likely fail. To fix the issue, use `tdnf install` to install all packages. For example:

Before:
```dockerfile
RUN apk add curl
```

After:
```dockerfile
RUN apk add curl || \
    (echo "Failed to install curl with apk, trying with tdnf" && \
    tdnf install -y tar gzip && \
    tdnf install -y curl)
```

## Version 2.9.0-preview
Fixed a number of bugs around output type serialization, and added the 'ade upgrade' functionality to ensure up-to-date CLI actions regardless of the base image.
