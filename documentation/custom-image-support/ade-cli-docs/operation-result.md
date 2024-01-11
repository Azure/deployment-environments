# 'ade operation-result' Command
The 'ade operation-result' command allows error details to be added to the environment being operated on in the event of an operation failure, as well as updating the ongoing operation.

The command is invoked as follows:
```
ade operation-result --code "ExitCode" --message "The operation failed!"
```

## Options
**--code**: A string detailing the exit code causing the failure of the operation

**--message**: A string detailing the error message for the operation failure.

**NOTE**: This operation should only be used just before exiting the container, as setting the operation in a Failed state does not permit additional CLI commands to successfully complete.