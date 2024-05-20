# 'ade upgrade' Command
The 'ade upgrade' command is used to ensure the CLI executable running in the deployment container is up-to-date with the latest bug fixes, regardless of the image being used. The command itself will check if the container contains the latest CLI version or not, and if the CLI needs to be updated, provides a link to download the package to the container. The command is used in conjunction with the 'upgradeCLi' function hosted in the core image that replaces the package inside the container and continues execution of the deployment. 

The 'ade upgrade' and upgradeCli function are run in the core entrypoint with the following code:
```bash
UPGRADE_CLI_URL=$(set -e; ade upgrade 2> >(tee -a $ADE_ERROR_LOG))
if [ -n "$UPGRADE_CLI_URL" ]; then
    verbose "Upgrading ADE CLI to latest version"
    wget -O ade-upgrade.zip $UPGRADE_CLI_URL
    mkdir ade-upgrade && unzip ade-upgrade.zip -d ade-upgrade && cd /ade-upgrade
    cp -f ade ../adecli/ade && cp -f appsettings.json ../adecli/ && cd ..
fi
verbose "ADE CLI is up to date"
```

**NOTE**: This should not be necessary to run multiple times, and if you are basing your custom image off of any of the ADE-authored images, you should not need to re-run this command. 