# 'ade files' Command Set
The 'ade files' command set allows a customer to upload and download files within the executing operation contianer for a certain environment to be used later in the container, or in later operation executions. This command set is also used to upload state files generated for certain Infrastructre-as-Code (IaC) providers.

The following commands are within this command set:
<!-- no toc -->
* ['ade files list'](#ade-files-list)
* ['ade files download'](#ade-files-download)
* ['ade files upload'](#ade-files-upload)

##  'ade files list'
This command will list the available files for download while within the environment container.

### Return Type
This command will return available files for download as an array of strings. Here is an example:
```
[
    "file1.txt",
    "file2.sh",
    "file3.zip"
]
```

## 'ade files download'
This command will download a selected file to a specified file location within the executing container. 

### Options
**--file-name**: The name of the file to download. This file name should be present within the list of available files returned from the 'ade files list' command. This option is required.

**--folder-path**: The folder path to download the file to within the container. This is not required, and the CLI will by default download the file to the current directory when the command is executed.

**--unzip**: This is a flag that can be set if you are wanting to download a zip file from the list of available files, and want the contents unzipped to the specified folder location. 

### Examples

The following command downloads a file to the current directory:
```
ade files download --file-name file1.txt
```

The following command downloads a file to a lower-level folder titled 'folder1'.
```
ade files download --file-name file1.txt --folder-path folder1
```

The last command downloads a zip file, and unzips the file contents into the current directory:
```
ade files download --file-name file3.zip --unzip
```

## 'ade files upload'
This command will upload either a singular file specified, or a zip folder specified as a folder path to the list of available files for the environment to access.

### Options
**--file-path**: The path of where the file exists from the current directory to upload. Either this option or the '--folder-path' option is requried to execute this command.

**--folder-path**: The path of where the folder exists from the current directory to upload as a zip file. The resulting accessible file will be accessible under the name of the lowest folder. Either this option or the '--file-path' option is required to execute this command. 

**NOTE**: Specifying a file or folder with the same name as an existing accessible file for the environment for this command will overwrite the previously saved file (i.e. if file1.txt is an existing accessible file, executing 'ade files --file-path file1.txt' will overwrite the previously saved file).

### Examples
The following command uploads a file from the current directory named 'file1.txt':
```
ade files upload --file-path "file1.txt"
```

This file will be later accessible by running:
```
ade files download --file-name "file1.txt"
```
The following command uploads a folder one level lower than the current directory named 'folder1' as a zip file named 'folder1.zip':
```
ade files upload --folder-path "folder1"
```

Finally, the following command uploads a folder two levels lower than the current directory at 'folder1/folder2' as a zip file named 'folder2.zip':
```
ade files upload --folder-path "folder1/folder2"
```