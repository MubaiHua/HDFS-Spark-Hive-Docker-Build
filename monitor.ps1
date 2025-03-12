[CmdletBinding()]
param(
    # User can specify the output CSV file name; default is "containerStats.csv"
    [Parameter(Mandatory=$false)]
    [string]$CsvName = "containerStats.csv"
)

# Flag to check if we're on the first iteration (to create the CSV with headers)
$firstIteration = $true

while ($true) {
    # Get IDs of all running containers
    $containerIDs = docker ps -q

    # Get the current timestamp for this snapshot
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    if (-not $containerIDs) {
        Write-Output "No running containers found at $timestamp."
    } else {
        # Create an array to hold stats objects
        $statsList = @()

        foreach ($containerID in $containerIDs) {
            # Retrieve docker stats for the container using --no-stream to get a single snapshot
            $statsOutput = docker stats $containerID --no-stream --format "{{.Container}},{{.Name}},{{.CPUPerc}},{{.MemUsage}},{{.MemPerc}},{{.NetIO}},{{.BlockIO}},{{.PIDs}}"
            
            # Split the comma-separated values into an array
            $values = $statsOutput.Split(',')
            
            # Create a custom object with properties (adding a timestamp field)
            $obj = [PSCustomObject]@{
                TimeStamp = $timestamp
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

        # If first iteration, write with header; otherwise, append without header
        if ($firstIteration) {
            $statsList | Export-Csv -Path $CsvName -NoTypeInformation
            $firstIteration = $false
        } else {
            $statsList | Export-Csv -Path $CsvName -NoTypeInformation -Append
        }
        Write-Output "Stats recorded at $timestamp"
    }
    
    # Wait for 5 seconds before the next recording
    Start-Sleep -Seconds 5
}
