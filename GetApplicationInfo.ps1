# Script written for PowerShell 7
if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Error "This script requires PowerShell 7 or higher."
        exit
    }

# Initialize the report array
$applicationReport = @()

function Get-ApplicationInfo {
    
    # Function to get the list of all installed applications and versions
    function Get-InstalledApplications {
        Write-Host "Retrieving list of installed applications and versions..." -ForegroundColor Yellow
        
        # If Get-AppxPackage is available, get UWP applications
        if (Get-Command -Name Get-AppxPackage -ErrorAction SilentlyContinue) {
            $uwpApps = Get-AppxPackage | Where-Object { $_.IsFramework -eq $false }
        } else {
            $uwpApps = @()
        }

        # Get packages installed via Windows Package Manager (if available)
        $wingetApps = Invoke-Expression 'winget list' 2>$null | Where-Object { $_ -match '([\w\s\-\.]+)\s+([\d\.]+)\s+' } | ForEach-Object {
            [PSCustomObject]@{
                'Name'    = $matches[1].Trim()
                'Version' = $matches[2].Trim()
            }
        }

        foreach ($app in $uwpApps + $wingetApps) {
            $appMessage = "Application: $($app.Name), Version: $($app.Version)"
            $script:applicationReport += $appMessage
        }

        Write-Host "Installed applications retrieval completed." -ForegroundColor Green
    }

    # Function to get the list of installed drivers and their versions
    function Get-InstalledDrivers {
        Write-Host "Retrieving list of installed drivers and versions..." -ForegroundColor Yellow
        $drivers = Get-CimInstance -ClassName Win32_PnPSignedDriver | Where-Object { $_.DriverVersion -ne $null }
        foreach ($driver in $drivers) {
            $driverMessage = "Driver: $($driver.DeviceName), Version: $($driver.DriverVersion)"
            $script:applicationReport += $driverMessage
        }
        Write-Host "Installed drivers retrieval completed." -ForegroundColor Green
    }

    # Function to get the list of active services
    function Get-ActiveServices {
        Write-Host "Retrieving list of active services..." -ForegroundColor Yellow
        $services = Get-Service -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Running' }
        foreach ($service in $services) {
            $serviceMessage = "Service: $($service.DisplayName), Status: $($service.Status)"
            $script:applicationReport += $serviceMessage
        }
        Write-Host "Active services retrieval completed." -ForegroundColor Green
    }

    # Call the functions
    Get-InstalledApplications
    Get-InstalledDrivers
    Get-ActiveServices

    # Return the report for further use
    return $applicationReport
}
