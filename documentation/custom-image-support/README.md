# ADE Custom Image Support
This page is designed to help customers understand how to build and utilize custom images within their environment definitions for deployments in Azure Deployment Environments. 

To see how the ADE-authored Core and ARM/Bicep images are structured, check out the Runner-Images folder [here](../../Runner-Images/README.md).

In order to use the ADE CLI, you will need to use an ADE-authored image as a base image. More information about the ADE CLI can be found [here](./ade-cli-docs/README.md).

## Creating and Building the Docker Image

The basic steps for creating a building an image configured for ADE are as follows:
1. Base your image off of an ADE-authored image or the image of your choice using the FROM statement
2. Install any necessary packages for your image using the RUN statement
3. Create a 'scripts' folder at the same level as your Dockerfile, store your 'deploy.sh' and 'delete.sh' files within it, and ensure those scripts are discoverable and executable inside your created container. Note that this is necessary for your deployment to work using the ADE core image.
4. Build and push your image to your container registry, and ensure it is accessible to ADE
5. Reference your image in the 'runner' property of your environment definition

### FROM Statement

If you are wanting to build a Docker image to utilize ADE deployments and access the ADE CLI, you will want to base your image off of one of the ADE-authored images. This can be done by including a FROM statement within a created DockerFile for your new image pointing to an ADE-authored image hosted on Microsoft Artifact Registry. When using ADE-authored images, it is recommended you build your custom image off of the ADE core image.

Here's an example of that FROM statement, pointing to the ADE-authored core image:
```docker
FROM mcr.microsoft.com/deployment-environments/runners/core:latest
```

This statement pulls the most recently-published core image, and makes it a basis for your custom image.

### RUN Statement

Next, you can use the RUN statement to install any additional packages you would need to use within your image. ADE-authored images are based off of the Azure CLI image, and have the ADE CLI and JQ packages pre-installed. You can learn more about the Azure CLI [here](https://learn.microsoft.com/en-us/cli/azure/), and the JQ package [here](https://devdocs.io/jq/).

Here's an example used in our Bicep image, installing the Bicep package within our Dockerfile.
```docker
RUN az bicep install
```

### Executing Operation Shell Scripts

Within the ADE-authored images, operations are determined and executed based off of the operation name. Currently, the two operation names supported are 'deploy' and 'delete', with plans to expand this moving forward.

To set up your custom image to utilize this structure, specify a folder at the level of your Dockerfile named 'scripts', and specify two files, 'deploy.sh', and 'delete.sh'. The 'deploy' shell script will run when your environment is created or redeployed, and the 'delete' shell script will run when your environment is deleted. You can see examples of this within this repository under the Runner-Images folder for the ARM-Bicep image.

To ensure these shell scripts are executable, add the following lines to your Dockerfile:
```docker
COPY scripts/* /scripts/
RUN find /scripts/ -type f -iname "*.sh" -exec dos2unix '{}' '+'
RUN find /scripts/ -type f -iname "*.sh" -exec chmod +x {} \;
```
### Building the Image

To build the image to be pushed to your registry, please ensure the Docker Engine is installed on your computer, navigate to the directory of your Dockerfile, and run the following command:
```
docker build . -t {YOUR_REGISTRY}.azurecr.io/{YOUR_REPOSITORY}:{YOUR_TAG}
```

For example, if you wanted to save your image under a repository within your registry named 'customImage', and you wanted to upload with the tag version of '1.0.0', you would run:

```
docker build . -t {YOUR_REGISTRY}.azurecr.io/customImage:1.0.0
```
## Pushing the Docker Image to a Registry
In order to use custom images, you will need to set up a publicly-accessible image registry with anonymous image pull enabled. This way, Azure Deployment Environments can access your custom image to execute in our container.

Azure Container Registry is an offering by Azure that provides storing of container images and similar artifacts.

To create a registry, which can be done through the Azure CLI, the Azure Portal, Powershell commands, and more, please follow one of the quickstarts [here](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-azure-cli).

To set up your registry to have anonymous image pull enabled, please run the following command in the Azure CLI:
```
az login
az acr login -n {YOUR_REGISTRY}
az acr update -n {YOUR_REGISTRY} --public-network-enabled true
az acr update -n {YOUR_REGISTRY} --anonymous-pull-enabled true
```
When you are ready to push your image to your registry, run the following command:
```
docker push {YOUR_REGISTRY}.azurecr.io/{YOUR_REPOSITORY}:{YOUR_TAG}
```

## Connecting the Image to your Environment Definition

When authoring environment definitions to use your custom image in their deployment, simply edit the 'runner' property on the manifest file (environment.yaml or manifest.yaml).
```yaml
runner: "{YOUR_REGISTRY}.azurecr.io/{YOUR_REPOSITORY}:{YOUR_TAG}"
```

## Image Building Quickstart Script
If you have a Dockerfile and scripts folder configured for ADE's extensibility model, you can run the script [here](../../Runner-Images/quickstart-image-build.ps1) to build and push to a specified Azure Container Registry (ACR) under the repository 'ade' and the tag 'latest'. This script requires your registry name and directory for your custom image, have the Azure CLI and Docker Desktop installed and in your PATH variables, and requires that you have permissions to push to the specified registry. You can call the script using the following command in Powershell:
```powershell
.\quickstart-image-build.ps1 -Registry '{YOUR_REGISTRY}' -Directory '{DIRECTORY_TO_YOUR_IMAGE}'
```

Additionally, if you would like to push to a specific repository and tag name, you can run:
```powershell
.\quickstart-image.build.ps1 -Registry '{YOUR_REGISTRY}' -Directory '{DIRECTORY_TO_YOUR_IMAGE}' -Repository '{YOUR_REPOSITORY}' -Tag '{YOUR_TAG}'
```

## Terraform + ADE Extensibility Model Repository
If you have set up an Azure Container Registry to contain images for your extensibility model workflow and are looking to use Terraform Infrastructure-as-Code (IaC) templates, we have setup a sample repository [here](https://github.com/Azure/ade-extensibility-model-terraform) containing an ADE-compatible image and a GitHub Action that builds and pushes the image to your Azure Container Registry. In order to use this method, you will need to do the following:
 - Fork the repository into your personal account
 - Allow GitHub Actions to connect to Azure via an Microsoft Entra ID application's federated credentials through OIDC. You will need to save the application's client ID as a secret within your forked repository, along with your subscription and Tenant ID. You can find more documentation about the process [here](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-cli%2Clinux).
 - Set up variables for your forked repository containing your personal Azure Container Registry name, your preferred repository name, and your preferred tag for the created image. You can modify your variables between workflow runs to push the generated image to different registries, repositories, and tags.

This repository is meant as a sample to give customers a starting point to deploy their environments with Terraform, allow customers to add additional customizations while using ADE's extensibility model, and easily upload their changes to their connected Azure Container Registry.

## Accessing Operation Logs And Error Details
To view error details with deployments and deletions, you can use the [Developer Portal](https://devportal.microsoft.com/) to view the error details stored in the file $ADE_ERROR_LOG at the end of the deployment by clicking on the 'See Details' button of a failed deployment, shown below:
![A Screenshot of a failed deployment of an environment with the 'See Details' button displayed](failedDeploymentCard.png)
![A Screenshot of the failed deployment's error details, specifically an invalid name for a storage account](deploymentErrorDetails.png)

Additionally, you can use the Azure CLI to view an environment's error details using the following command:
```bash
az devcenter dev environment show --environment-name {YOUR_ENVIRONMENT_NAME} --project {YOUR_PROJECT_NAME}
```

To view the operation logs for an environment deployment or deletion you can use the Azure CLI to retrieve the latest operation for your environment, and then view the logs for that operation ID, shown below:
```bash
# Get list of operations on the environment, choose the latest operation
az devcenter dev environment list-operation --environment-name {YOUR_ENVIRONMENT_NAME} --project {YOUR_PROJECT_NAME}
# Using the latest operation ID, view the operation logs
az devcenter dev environment show-logs-by-operation --environment-name {YOUR_ENVIRONMENT_NAME} --project {YOUR_PROJECT_NAME} --operation-id {LATEST_OPERATION_ID}
```

# Getting help or providing feedback

If you are facing any issues or have feedback to share on Terraform support, please create a new issues in [GitHub Issues](https://github.com/Azure/deployment-environments/issues). 

If you have general feedback about the product, please submit the feedback on the [Developer Community](https://developercommunity.visualstudio.com/deploymentenvironments) or by [emailing us directly](mailto:adesupport@microsoft.com).
