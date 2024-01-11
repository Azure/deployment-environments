# Runner Images - 2.2.0-preview

## Changes
This tag added the implmentation of logging using the ADE CLI 'ade log' command, to record all processes of an environment operation
into a log file to be accessed and analyzed later historically.

Additionally, this new tag added the usage of the ADE CLI 'ade operation-result' command, so that if the executing operation exits the container with a non-zero exit code, the error causing the operation failure is exposed on the environment's error details, accessible in the DevPortal or by calling the appropriate API endpoint. This allows for clear diagnosis of the failing issue during the operation, instead of sifting through the container logs for the error. 