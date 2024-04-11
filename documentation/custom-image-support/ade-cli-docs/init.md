# 'ade init' Command
The 'ade init' command is used to initialize the container for ADE by setting necessary environment variables and downloading the environment definition specified for deployment. The command itself prints out shell commands, which are then evaluated within the core entrypoint using the following command:

```bash
eval "$(ade init)"
```

**NOTE**: This should not be necessary to run multiple times, and if you are basing your custom image off of any of the ADE-authored images, you should not need to re-run this command. 