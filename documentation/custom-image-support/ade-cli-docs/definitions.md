# 'ade definitons' Command Set
The 'ade definitons' command allows the user to see information related to the definition chosen for the environment being operated on, and download the related files, such as the primary and linked Infrastructure-as-Code (IaC) templates, to a specified file location. 

The following commands are within this command set:
<!-- no toc -->
- ['ade definitions list'](#ade-definitions-list)
- ['ade definitons download'](#ade-definitons-download)

## 'ade definitions list'
The 'list' command is invoked as follows:

```definitionValue=$(ade definitions list)```

This command returns a data object describing the various properties of the environment's definition.

### Return Type
This command returns a JSON object describing the environment definition. Here is an example of the return object, based on one of our sample environment definitions:
```
{
    "id": "/projects/PROJECT_NAME/catalogs/CATALOG_NAME/environmentDefinitions/appconfig",
    "name": "AppConfig",
    "catalogName": "CATALOG_NAME",
    "description": "Deploys an App Config.",
    "parameters": [
        {
            "id": "name",
            "name": "name",
            "description": "Name of the App Config",
            "type": "string",
            "readOnly": false,
            "required": true,
            "allowed": []
        },
        {
            "id": "location",
            "name": "location",
            "description": "Location to deploy the environment resources",
            "default": "westus3",
            "type": "string",
            "readOnly": false,
            "required": false,
            "allowed": []
        }
    ],
    "parametersSchema": "{\"type\":\"object\",\"properties\":{\"name\":{\"title\":\"name\",\"description\":\"Name of the App Config\"},\"location\":{\"title\":\"location\",\"description\":\"Location to deploy the environment resources\",\"default\":\"westus3\"}},\"required\":[\"name\"]}",
    "templatePath": "CATALOG_NAME/AppConfig/appconfig.bicep",
    "contentSourcePath": "CATALOG_NAME/AppConfig"
}
```

### Utilizing Returned Property Values

You can assign environment variables to certain properties of the returned definition JSON object by utilizing the JQ library (pre-installed on ADE-authored images), using the following format:\
```environment_name=$(echo $definitionValue | jq -r ".Name")```

You can learn more about advanced filtering and other uses for the JQ library [here](https://devdocs.io/jq/).

## 'ade definitons download'
This command is invoked as follows:\
```ade definitions download --folder-path EnvironmentDefinition```

This command will download the main and linked Infrastructure-as-Code (IaC) templates and any other associated files with the provided template.

### Options

**--folder-path**: The folder path to download the environment definition files to. If not specified, the command will store the files in a folder named 'EnvironmentDefinition' at the current directory level at execution time.

### What Files Do I Have Access To?
Any files stored at or below the level of the environment definition's manifest file (environment.yaml or manifest.yaml) within the catalog repository will be accessible when invoking this command. 

You can learn more about curating environment definitions and the catalog repository structure through the following links:

- [Add and Configure a Catalog in ADE](https://learn.microsoft.com/en-us/azure/deployment-environments/how-to-configure-catalog?tabs=DevOpsRepoMSI)
- [Add and Configure an Environment Definition in ADE](https://learn.microsoft.com/en-us/azure/deployment-environments/configure-environment-definition)
- [Best Practices For Designing Catalogs](https://learn.microsoft.com/en-us/azure/deployment-environments/best-practice-catalog-structure)