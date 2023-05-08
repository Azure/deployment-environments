# OpenAI Search
This template helps the developer quickly set up the infrastructure about OpenAI Search with enterprise own data for searching.

This repo is the just infrastructure part. If you want to deploy application and data, please refer to [repo](https://github.com/luxu-ms/azure-search-openai-demo)

## Prerequisites
Ensure that your machine has installed the following items
- [Python 3+](https://www.python.org/downloads/)
   - **Important**: Python and the pip package manager must be in the path in Windows for the setup scripts to work.
   - **Important**: Ensure you can run `python --version` from console. On Ubuntu, you might need to run `sudo apt install python-is-python3` to link `python` to `python3`.    
- [Node.js](https://nodejs.org/en/download/)
- [Git](https://git-scm.com/downloads)
- [Powershell 7+ (pwsh)](https://github.com/powershell/powershell) - For Windows users only.
   - **Important**: Ensure you can run `pwsh.exe` from a PowerShell command. If this fails, you likely need to upgrade PowerShell.

>NOTE: Your Azure Account must have `Microsoft.Authorization/roleAssignments/write` permissions, such as [User Access Administrator](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#user-access-administrator) or [Owner](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#owner). 

- [Dev Center](https://learn.microsoft.com/en-us/azure/deployment-environments/quickstart-create-and-configure-devcenter), [Project](https://learn.microsoft.com/en-us/azure/deployment-environments/quickstart-create-and-configure-projects) and [Catalog](https://learn.microsoft.com/en-us/azure/deployment-environments/how-to-configure-catalog)
   - **Important**: Ensure the user is assigned role "Deployment Environments User" to the project
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) and [Azure CLI extension for Dev Center](https://learn.microsoft.com/en-us/azure/deployment-environments/how-to-install-devcenter-cli-extension)
- Clone the application and data [repo](https://github.com/luxu-ms/azure-search-openai-demo)

## How to setup
Typically, there are two ways to quickly setup your own OpenAI and Cognitive search application.
1. Leverage the script "deploy.ps1" in the root folder to automatically deploy.
2. Manually deploy the infra, application and data.

### Leverage the script "deploy.ps1" in the root folder to automatically deploy
1. Use "az login" to login
2. Run the script "deploy.ps1" in the PowerShell by the command below:
```
.\deploy.ps1 <environment name> <project name> <dev center name> <environment type> <catalog name> <catalog item name> <principal id>
```
>NOTE: <principal id> is the user id that you use in step 1. If you do not know the user id, you can go to "Azure Active Directory" -> "Users" to search your user and will find the "Object ID"

### Manually deploy the infra, application and data
1. Use [Dev Portal](https://devportal.microsoft.com/) to deploy the infra 
* Click "+New" -> "New environment"
* Give a name for the environment name (e.g. dev1)
* Select the environment type (e.g. Dev/Test)
* Select catalog item (e.g. azure-search-openai-demo)
* Click "Next"
* Input the required parameters (e.g. "environmentName" is dev1, "principalId" is your user's Object ID which can be found in the Azure Active Directory's users)
* Click "Create"

2. Deploy the application to App service
* Go to the folder "app" in root folder, run "start.ps1" to build backend and frontend
* In VS Code, right click "backend" folder and select "Deploy to Web App.." (Note: If no such option, please install "Azure Tools" extension in VS Code)
* Follow the guide to deploy to your app service which is created in step 1

3. Upload the test data to storage account
In step 1, find the created resource: storage account name, search service name and form recognizer service name.
Execute the commands below to upload the test data.
```
$storageAccountName='<storage account name>'
$searchServiceName='<search service name>'
$formRecognizerServiceName='<form recognizer service name>'
.\scripts\prepdocs.ps1 $storageAccountName $searchServiceName $formRecognizerServiceName
```
