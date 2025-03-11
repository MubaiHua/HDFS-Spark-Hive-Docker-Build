# Define the output CSV file
$OutputFile = "container_usage.csv"

# Write the header to the CSV file
"Timestamp,ContainerName,ContainerID,CPU_Percentage,Memory_Usage" | Out-File $OutputFile

Write-Host "Recording container stats. Press Ctrl+C to stop."

# Loop indefinitely, recording stats every second
while ($true) {
    # Get current timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Capture Docker stats for all containers, including container name and ID
    $stats = docker stats --no-stream --format "{{.Name}},{{.Container}},{{.CPUPerc}},{{.MemUsage}}"

    # Append each line of output with the timestamp
    foreach ($line in $stats) {
        "$timestamp,$line" | Out-File $OutputFile -Append
    }
    
    # Wait 1 second before next recording
    Start-Sleep -Seconds 1
}
