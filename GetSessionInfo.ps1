# GetSessionInfo.ps1
# Please note this script must be run with elevated permissions
# Script written for PowerShell 7

function Get-SessionInfo {
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Error "This script requires PowerShell 7 or higher."
        exit
    }

    # Initialize the report array
    $sessionReport = @()

    # Function to retrieve the current username
    function Get-Username {
        Write-Host "Retrieving current username..." -ForegroundColor Yellow
        $username = $env:USERNAME
        $usernameMessage = "Current Username: $username"
        $sessionReport += $usernameMessage
        Write-Host $usernameMessage
        Write-Host "Username retrieval completed." -ForegroundColor Green
    }

    # Function to get the last boot time of the device
    function Get-LastBootTime {
        Write-Host "Retrieving last boot time..." -ForegroundColor Yellow
        $lastBootTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
        $bootTimeMessage = "Last Boot Time: $lastBootTime"
        $sessionReport += $bootTimeMessage
        Write-Host $bootTimeMessage
        Write-Host "Last boot time retrieval completed." -ForegroundColor Green
    }

    # Function to get the last session login time
    function Get-LastLoginTime {
        Write-Host "Retrieving last session login time..." -ForegroundColor Yellow
        # Get the most recent interactive logon event (Logon Type 2)
        $filterXML = @"
<QueryList>
            <Query Id="0" Path="Security">
                <Select Path="Security">
                *[System[(EventID=4624)]]
                and
                *[EventData[Data[@Name='LogonType'] and (Data='2')]]
            </Select>
        </Query>
        </QueryList>
"@
    $lastLogin = Get-WinEvent -FilterXml $filterXML -MaxEvents 1
    if ($lastLogin) {
        $loginTimeMessage = "Last Session Login Time: $($lastLogin.TimeCreated)"
        $script:sessionReport += $loginTimeMessage
        Write-Host $loginTimeMessage
    } else {
        Write-Host "No interactive logon events found." -ForegroundColor Yellow
    }
    Write-Host "Last session login time retrieval completed." -ForegroundColor Green
}


    # Function to retrieve the OS version and build
    function Get-OSInfo {
        Write-Host "Retrieving OS version and build..." -ForegroundColor Yellow
        $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
        $osInfoMessage = "OS Version: $($osInfo.Version) | Build: $($osInfo.BuildNumber)"
        $sessionReport += $osInfoMessage
        Write-Host $osInfoMessage
        Write-Host "OS version and build retrieval completed." -ForegroundColor Green
    }

    # Function to check for for most recent OS updates
    function Check-OSUpdates {
        Write-Host "Checking for OS updates..." -ForegroundColor Yellow
        $updates = Get-HotFix | Sort-Object InstalledOn -Descending
    
        if ($updates) {
            $mostRecentUpdate = $updates[0].HotFixID
            Write-Host "Most recent OS update installed: $mostRecentUpdate" -ForegroundColor Cyan
            $recentUpdates = $updates | Select-Object -First 10
            $updateMessages = @("The last 10 updates installed are:")
            foreach ($update in $recentUpdates) {
                $updateMessages += "HotFixID: $($update.HotFixID), Installed On: $($update.InstalledOn)"
            }
            $sessionReport += $updateMessages
        } else {
            $updateMessage = "No OS updates found."
            $sessionReport += $updateMessage
            Write-Host $updateMessage -ForegroundColor Red
        }

        Write-Host "OS update check completed." -ForegroundColor Green
    }


    # Call the functions
    Get-Username
    Get-LastBootTime
    Get-LastLoginTime
    Get-OSInfo
    Check-OSUpdates

    # Return the report for use in BasicTroubleshooting Script
    Write-Host $sessionReport
    return $sessionReport
}

