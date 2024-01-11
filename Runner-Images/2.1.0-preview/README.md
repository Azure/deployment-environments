# Runner Images - 2.1.0-preview

## Changes
This tag added the first implementations of the ADE CLI, using the 'ade environments', 'ade definitions', 'ade files', and 'ade outputs' commands. 

The 'ade environments' command is used to retrieve information for the environment being deployed or deleted, and provides inputs for various variables used within the container. Similarly, the 'ade definitions' command is used to retrieve information for the definition being used within the operaiton and provide inputs for additional variables within the container.

The 'ade files' command is used to retrieve any state files generated for environments, so as to keep an accurate record of the state of the environment, and update and reupload the state file if necessary. Finally, the 'ade outputs' command is used to retrieve any outputs generated as a result of a successful deployment and store them with the state file and other associated information with the environment.