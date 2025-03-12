[CmdletBinding()]
param(
    # User can specify the output CSV file name; default is "containerStats.csv"
    [Parameter(Mandatory=$false)]
    [string]$CsvName = "containerStats.csv"
)

# Get IDs of all running containers
$containerIDs = docker ps -q

if (-not $containerIDs) {
    Write-Output "No running containers found."
    exit
}

# Create an array to hold stats objects
$statsList = @()

foreach ($containerID in $containerIDs) {
    # Retrieve docker stats for the container using --no-stream to get a single snapshot
    $statsOutput = docker stats $containerID --no-stream --format "{{.Container}},{{.Name}},{{.CPUPerc}},{{.MemUsage}},{{.MemPerc}},{{.NetIO}},{{.BlockIO}},{{.PIDs}}"
    
    # Split the comma-separated values into an array
    $values = $statsOutput.Split(',')

    # Create a custom object with properties matching the CSV headers
    $obj = [PSCustomObject]@{
        Container = $values[0].Trim()
        Name      = $values[1].Trim()
        CPUPerc   = $values[2].Trim()
        MemUsage  = $values[3].Trim()
        MemPerc   = $values[4].Trim()
        NetIO     = $values[5].Trim()
        BlockIO   = $values[6].Trim()
        PIDs      = $values[7].Trim()
    }
    $statsList += $obj
}

# Export the collected statistics to the specified CSV file
$statsList | Export-Csv -Path $CsvName -NoTypeInformation

Write-Output "Container statistics exported to $CsvName"
