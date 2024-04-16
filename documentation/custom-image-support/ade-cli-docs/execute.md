# 'ade execute' Command
The 'ade execute' command is used to provide implicit logging for scripts executed inside the container. This way, any standard output or standard error content produced during the command will be logged to the operation's log file for the environment, and can be accessed using the Azure CLI.

**NOTE**: It is recommended that all standard error from this command is also piped to the error log file specified at the environment variable `$ADE_ERROR_LOG`, so that environment error details are easily populated and surfacable on the Developer Portal.

## Options
**--operation**: A string input specifying the operation being performed with the command. Typically, this can be supplied by using the `$ADE_OPERATION_NAME` environment variable.

**--command**: The commmand to execute and record logging for. 

## Examples

This command will execute 'deploy.sh':
```
ade execute --operation $ADE_OPERATION_NAME --command "./deploy.sh" 2> >(tee -a $ADE_ERROR_LOG)
```