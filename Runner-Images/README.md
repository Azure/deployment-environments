# ADE Runner Images

## Featured Repos
+ Core: Core ADE Image
+ ARM-Bicep: ADE Image for ARM/Bicep Deployments/Deletions

## About Azure Deployment Environments
Azure Deployment Environments empowers development teams to quickly and easily spin up app infrastructure with project-based templates that establish consistency and best practices while maximizing security. This on-demand access to secure environments accelerates the stages of the software development lifecycle in a compliant and cost-efficient way.

The provided images for ADE allow customers to create custom images for their deployments to be executed with, utilizing additional custom scripts or steps that fit their deployment workflow.

## How to Use the Images
In order to use these images as a base for your custom images, add the following line of code to your Dockerfile:
``` 
FROM mcr.microsoft.com/deployment-environments/runners/{REPO_NAME}:{IMAGE_VERSION}
```

In addtion, by using the provided runner images, you can invoke the ADE CLI within your deployment. The ADE CLI, along with custom images, allows a customer to upload and download files connected to the environment to utilize during deployment and deletion scenarios, record addtional logging, utilize outputs from the infrastructure deployment, and access additional information about their environment and the environment definition. More information concerning the ADE CLI can be found [here](../documentation/custom-image-support/ade-cli-docs/README.md).

You can find more information about Custom Image Support [here](../documentation/custom-image-support/README.md).

## Available Image Repositories and Versions
- Core: 2.7.0-preview(latest), latest
- ARM/Bicep: 2.7.0-preview(latest), latest

## Image Building Quickstart Script
If you have a Dockerfile and scripts folder configured for ADE's extensibility model, you can run the script [here](../../Runner-Images/quickstart-image-build.ps1) to build and push to a specified Azure Container Registry (ACR) under the repository 'ade' and the tag 'latest'. This script requires your registry name and directory for your custom image, have the Azure CLI and Docker Desktop installed and in your PATH variables, and requires that you have permissions to push to the specified registry. You can call the script using the following command in Powershell:
```powershell
.\quickstart-image-build.ps1 -Registry '{YOUR_REGISTRY}' -Directory '{DIRECTORY_TO_YOUR_IMAGE}'
```

Additionally, if you would like to push to a specific repository and tag name, you can run:
```powershell
.\quickstart-image.build.ps1 -Registry '{YOUR_REGISTRY}' -Directory '{DIRECTORY_TO_YOUR_IMAGE}' -Repository '{YOUR_REPOSITORY}' -Tag '{YOUR_TAG}'
```

## Support

[File an issue](https://github.com/Azure/deployment-environments/issues)

[Additional Documentation about ADE](https://learn.microsoft.com/en-us/azure/deployment-environments/)

## License
- Legal Notice: [Container License Information](https://aka.ms/mcr/osslegalnotice)

See license terms [here](https://github.com/Azure/deployment-environments/blob/main/LICENSE).
