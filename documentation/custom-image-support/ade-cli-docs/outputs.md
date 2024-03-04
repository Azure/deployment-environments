# 'ade outputs' Command Set
The 'ade outputs' command allows a customer to upload outputs from the deployment of an Infrastructure-as-Code (IaC) template to be accessed from the Outputs API for ADE. 

## 'ade outputs upload' 
This command uploads the contents of a JSON file specified in the ADE EnvironmentOutput format to the environment, to be accessed later using the Outputs API for ADE.

### Options
**--file**: A file location containing a JSON object to upload.

### Examples

This command uploads a .json file named 'outputs.json' to the environment to serve as the outputs for the successful deployment:
```
ade outputs upload --file outputs.json
```

### EnvironmentOutputs Format
In order for the incoming JSON file to be serialized properly and accepted as the environment's deployment outputs, the object submitted must follow the below structure:
```
{
    "outputs": {
        "output1": {
            "type": "string",
            "value": "This is output 1!",
            "sensitive": false
        },
        "output2": {
            "type": "int",
            "value": 22,
            "sensitive": false
        },
        "output3": {
            "type": "string",
            "value": "This is a sensitive output",
            "sensitive" true
        }
    }
}
```

This format is adapated from how ARM deployments report outputs of a deployment, along with an additional property of "sensitive". The "sensitive" property is optional to provide, but will restrict the output to only being able to be viewed by those with privileged access, such as the creator of the environment.

Acceptable types for outputs are "string", "int", "boolean", "array", and "object".

## How to Access Outputs

To access outputs either while within the container or post-execution, a customer can use the Outputs API for ADE, accessible either by calling the API endpoint or using the AZ CLI.

In order to access the outputs within the container, a customer will need to install the Azure CLI to their image (pre-installed on ADE-authored images), and run the following commands: 
```
az login

az devcenter dev environment show-outputs --dev-center-name DEV_CENTER_NAME --project-name PROJECT_NAME --environment-name ENVIRONMENT_NAME
```