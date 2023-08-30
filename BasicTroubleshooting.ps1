# Basic Troubleshooting/L1 Information gathering script to gather system information.
# Must be run as admin to gather session information.

# Include Network Troubleshooting Module
. .\NetworkTroubleshooting.ps1

# Include Session Info Module -- Must be run as admin
. .\GetSessionInfo.ps1

# Include Hardware Info Module
. .\GetHardwareInfo.ps1

# Include Application Info Module
. .\GetApplicationInfo.ps1

# Create an array to accumulate the report data.
$output = @()

# Run network troubleshooting, call the Get-NetworkDiagnostics function from NetworkTroubleshooting.ps1
Write-Host 'Conducting Network Troubleshooting'
$networkDiagnosticsReport = Get-NetworkInfo
$output += "===== Network Diagnostics Report ====="
$output += $networkDiagnosticsReport
$output += "" # for a blank line

# Run session information gathering, call the Get-SessionInfo function from GetSessionInfo.ps1
Write-Host 'Gathering Session Information'
$sessionInfoReport = Get-SessionInfo
$output += "===== Session Information Report ====="
$output += $sessionInfoReport
$output += ""

# Run hardware information gathering, call the Get-HardwareInfo function from GetHardwareInfo.ps1
Write-Host 'Gathering Hardware Information'
$hardwareInfoReport = Get-HardwareInfo
$output += "===== Hardware Information Report ====="
$output += $hardwareInfoReport
$output += ""

# Run application information gathering, call the Get-ApplicationInfo function from GetApplicationInfo.ps1
Write-Host 'Gathering Application and Service Information'
$appInfoReport = Get-ApplicationInfo
$output += "===== Application and Service Information Report ====="
$output += $appInfoReport
$output += ""

# Create a C:\Scripts\ folder if does not already exist.
if (-not (Test-Path -Path "C:\Scripts\")) {
    New-Item -Path "C:\Scripts\" -ItemType Directory -Force
    Write-Host "Created C:\Scripts\ directory" -ForegroundColor Green
}

# Generate a timestamp for the report filename.
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportPath = "C:\Scripts\sysinfo_$timestamp.txt"

# Export the combined report to the desired path.
$output | Out-File $reportPath -Encoding utf8
Write-Host "Report exported to $reportPath" -ForegroundColor Cyan
