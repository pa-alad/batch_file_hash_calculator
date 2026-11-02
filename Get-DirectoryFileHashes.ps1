<#
.SYNOPSIS
Calculates selected hashes for files in a directory and displays them in a readable table.

.DESCRIPTION
FileNameRegex is matched against each file's name (not its full path) and is case-insensitive.
FileName displays each file's path relative to the target directory, excluding the target directory itself.
Files are displayed in alphabetical order. By default, only files directly in the target directory are included.

.PARAMETER Path
Directory containing the files to hash. Defaults to the current directory.

.PARAMETER FileNameRegex
Regular expression used to select file names. Defaults to all files.

.PARAMETER Algorithms
One or more algorithms supported by Get-FileHash: MD5, SHA1, SHA256, SHA384, or SHA512.
Defaults to SHA256.

.PARAMETER Recurse
Include files in subdirectories.

.EXAMPLE
.\Get-DirectoryFileHashes.ps1 -Path 'C:\Data' -FileNameRegex '\.(txt|csv)$' -Algorithms SHA256,SHA512

.EXAMPLE
.\Get-DirectoryFileHashes.ps1 -Path './logs' -FileNameRegex '^app-.*\.log$' -Recurse
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Path = '.',

    [Parameter()]
    [string]$FileNameRegex = '.*',

    [Parameter()]
    [ValidateSet('MD5', 'SHA1', 'SHA256', 'SHA384', 'SHA512')]
    [string[]]$Algorithms = @('SHA256'),

    [Parameter()]
    [switch]$Recurse
)

if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
    throw "Directory not found: $Path"
}

$rootPath = [System.IO.Path]::GetFullPath((Resolve-Path -LiteralPath $Path).Path)
$rootPrefix = $rootPath.TrimEnd(
    [System.IO.Path]::DirectorySeparatorChar,
    [System.IO.Path]::AltDirectorySeparatorChar
) + [System.IO.Path]::DirectorySeparatorChar

try {
    $namePattern = [regex]::new(
        $FileNameRegex,
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor
        [System.Text.RegularExpressions.RegexOptions]::CultureInvariant
    )
}
catch {
    throw "Invalid file-name regular expression '$FileNameRegex': $($_.Exception.Message)"
}

$files = @(Get-ChildItem -LiteralPath $Path -File -Recurse:$Recurse |
    Where-Object { $namePattern.IsMatch($_.Name) } |
    Sort-Object -Property Name, FullName)

if ($files.Count -eq 0) {
    Write-Output "No files matched '$FileNameRegex' in '$Path'."
    return
}

$results = foreach ($file in $files) {
    foreach ($algorithm in $Algorithms) {
        $hash = Get-FileHash -LiteralPath $file.FullName -Algorithm $algorithm -ErrorAction Stop
        $relativePath = $file.FullName.Substring($rootPrefix.Length)

        [pscustomobject]@{
            FileName  = $relativePath
            Algorithm = $hash.Algorithm
            Hash      = $hash.Hash
        }
    }
}

$results |
    Sort-Object -Property FileName, Algorithm |
    Format-Table -Property FileName, Algorithm, Hash -AutoSize -Wrap
