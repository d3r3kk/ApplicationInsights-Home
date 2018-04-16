<#
.SYNOPSIS
    Extract information about a Nuget package and make it available as an 
    object.

.DESCRIPTION
    Given a nuget package file, unzip the package and find the nuspec file
    contained within. Using that nuspec file, extract all the details about
    the nuget package and create a new PSObject describing the package.

.EXAMPLE
    PS C:\> Get-NugetPackageDetail -Verbose -Package C:\Path\To\Package.1.2.3.nupkg
    Extracts all the information containined in package Package ver 1.2.3 and
    returns it to stdout as an object.
#>
Param(
# Parameter help description
[Parameter(Mandatory=$true)]
[string]
$Package
)

Write-Verbose "Received command line input:"
Write-Verbose "    Package: '$Package'"

# Functions ################################################

<#
 # Unzips a nuget package to a 'temp' or a given location, and returns that location.
 #>
function Expand-NugetPackage
{
Param(
    # Specifies a path to a Nuget package file '.nupkg'
    [Parameter(Mandatory=$true,Position=0)]
    [ValidateNotNullOrEmpty()]
    [Alias("Path")]
    [string]
    $NugetPackagePath,
    # Specifies the path to the location to unzip the files into. Path is assumed to be a folder name. If the folder doesn't exist it will be created.
    [Parameter(Mandatory=$false,Position=1,ValueFromPipelineByPropertyName=$true)]
    [Alias("OutputPath")]
    [ValidateNotNullOrEmpty()]
    [string]
    $OutPath
)

    Write-Verbose "Expand-NugetPackage: Input values given"
    Write-Verbose "    NugetPackagePath: '$NugetPackagePath'"
    Write-Verbose "    OutPath: '$OutPath'"

    if (-not $OutPath)
    {
        $OutPath = Join-Path -Path [System.IO.Path]::GetTempPath -ChildPath [System.IO.Path]::GetRandomFileName
        Write-Verbose "No output path given, constructing TEMP path '$OutPath'"
    }

    if (-not (Test-Path -Path $OutPath))
    {
        New-Item -ItemType Directory -Path $OutPath
        Write-Verbose "Output path didn't exist. Created path '$OutPath'"
    }

    Add-Type -assembly "System.IO.Compression.FileSystem"
    [System.IO.Compression.Zipfile]::ExtractToDirectory($NugetPackagePath, $OutPath)

    return $OutPath
}





if (-not (Test-Path -Path $Package))
{
    Write-Error "Package path given does not exist."
}

$unzippedFilesPath = Expand-NugetPackage -NugetPackagePath $Package
