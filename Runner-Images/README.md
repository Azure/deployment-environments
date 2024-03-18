# ADE Runner Images

## Featured Repos
+ Core: Core ADE Image
+ ARM-Bicep: ADE Image for ARM/Bicep Deployments/Deletions
+ Terraform: ADE Image for Terraform Deployments/Deletions

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
Core: 2.5.0-preview(latest), latest
ARM/Bicep: 2.5.0-preview(latest), latest
Terraform: 2.5.0-preview(latest), latest

## Support

[File an issue](https://github.com/Azure/deployment-environments/issues)

[Additional Documentation about ADE](https://learn.microsoft.com/en-us/azure/deployment-environments/)

## License
- Legal Notice: [Container License Information](https://aka.ms/mcr/osslegalnotice)

See license terms [here](https://github.com/Azure/deployment-environments/blob/main/LICENSE).