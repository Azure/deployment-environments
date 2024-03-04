# 'ade environment' Command
The 'ade environment' command allows the user to see information related to their environment the operation is being performed on.

The command is invoked as follows:

```environmentValue=$(ade environment)```

This command returns a data object describing the various properties of the environment.

### Return Type
This command returns a JSON object describing the environment. Here is an example of the return object:
```
{
    "uri": "https://TENANT_ID-DEVCENTER_NAME.DEVCENTER_REGION.devcenter.azure.com/projects/PROJECT_NAME/users/USER_ID/environments/ENVIRONMENT_NAME",
    "name": "ENVIRONMENT_NAME",
    "environmentType": "ENVIRONMENT_TYPE",
    "user": "USER_ID",
    "provisioningState": "PROVISIONING_STATE",
    "resourceGroupId": "/subscriptions/SUBSCRIPTION_ID/resourceGroups/RESOURCE_GROUP_NAME",
    "catalogName": "CATALOG_NAME",
    "environmentDefinitionName": "ENVIRONMENT_DEFINITION_NAME",
    "parameters": {
        "location": "locationInput",
        "name": "nameInput"
    },
    "location": "regionForDeployment"
}
```

### Utilizing Returned Property Values

You can assign environment variables to certain properties of the returned definition JSON object by utilizing the JQ library (pre-installed on ADE-authored images), using the following format:\
```environment_name=$(echo $environment | jq -r ".Name")```

You can learn more about advanced filtering and other uses for the JQ library [here](https://devdocs.io/jq/).
