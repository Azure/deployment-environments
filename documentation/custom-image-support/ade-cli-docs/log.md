# 'ade log' Command Set
The 'ade log' commands are used to record details regarding the execution of the operation on the environment while within the container. This command offers a number of different logging levels, which can be then accessed after the operation has finished to analyze, and a customer can specify different files to log to for different logging scenarios.

## Options
**--content**: A string input containing the information to log. This option is required for this command.

**--type**: The level of log (verbose, log, or error) to log the content under. If not specified, the CLI will log the content at the 'log' level.

**--file**: The file to log the content to. If not specified, the CLI will log to a .log file specified by the unique Operation ID of the executing operation.

## Examples

This command will log a simple string to the default log file:
```
ade log --content "This is a log"
```

This command will log an error to the default log file:
```
ade log --type error --content "This is an error."
```

This command will log a simple string to a specified file named 'specialLogFile.txt':
```
ade log --content "This is a special log." --file "specialLogFile.txt"
```

**NOTE**: If you are using an ADE-authored image as a base for your custom image, you will not need to log all statements explicitly. When using `ade execute` in your workflow, ADE will pipe all standard output and standard error logging to the operation's log file. If you would like to log to additional files, or are not executing scripts using `ade execute`, then it would be appropriate to use `ade log`.