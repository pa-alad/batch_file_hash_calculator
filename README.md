# Get-DirectoryFileHashes

Calculates selected hashes for files in a directory and displays them in a readable table.

## Description

`FileNameRegex` is matched against each file's name (not its full path) and is case-insensitive. Files are displayed in alphabetical order. By default, only files directly in the target directory are included.

## Parameters

| Parameter | Description | Default |
|---|---|---|
| `Path` | Directory containing the files to hash. | `.` (current directory) |
| `FileNameRegex` | Regular expression used to select file names. | `.*` (all files) |
| `Algorithms` | One or more algorithms supported by `Get-FileHash`: `MD5`, `SHA1`, `SHA256`, `SHA384`, or `SHA512`. | `SHA256` |
| `Recurse` | Include files in subdirectories when specified. | Off |

## Examples

Hash `.txt` and `.csv` files in `C:\Data` with SHA256 and SHA512:

```powershell
.\Get-DirectoryFileHashes.ps1 -Path 'C:\Data' -FileNameRegex '\.(txt|csv)$' -Algorithms SHA256,SHA512
```

Hash matching application log files in `./logs`, including subdirectories:

```powershell
.\Get-DirectoryFileHashes.ps1 -Path './logs' -FileNameRegex '^app-.*\.log$' -Recurse
```
