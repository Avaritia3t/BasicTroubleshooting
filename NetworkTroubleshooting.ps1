# Script written for PowerShell 7
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Error "This script requires PowerShell 7 or higher."
    exit
}

# Initialize the report array
$report = @()

function Get-NetworkInfo {

# Function to check network connection
function Check-NetworkConnection {
    Write-Host "Checking network connection..." -ForegroundColor Yellow
    $connectedNetworks = Get-NetConnectionProfile
    $networkProfile = ""

    if (-not $connectedNetworks) {
        $networkProfile = "Device is not connected to any network."
    } else {
        foreach ($network in $connectedNetworks) {
            $connectionType = $network.InterfaceAlias
            if ($connectionType -like "*Wi-Fi*") {
                $networkProfile += "Device is connected to Wi-Fi SSID: $($network.Name)"
            } elseif ($connectionType -like "*Ethernet*") {
                $networkProfile += "Device is connected via Ethernet to network: $($network.Name)"
            } else {
                $networkProfile += "Device is connected via $connectionType to network: $($network.Name)"
            }
        }
    }

    $script:report += $networkProfile
    Write-Host "Network connection check completed." -ForegroundColor Green
}

# Function to retrieve MAC address
function Get-MacAddress {
    Write-Host "Retrieving MAC address..." -ForegroundColor Yellow
    $mac = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -ExpandProperty MacAddress -First 1
    $macMessage = "MAC Address: $mac"
    $script:report += $macMessage
    Write-Host "MAC address retrieval completed." -ForegroundColor Green
}

# Function to get IP Address
function Get-IPAddressInfo {
    Write-Host "Retrieving IP address information..." -ForegroundColor Yellow

    # Get IP addresses (excluding link-local and loopback addresses)
    $ipAddresses = Get-NetIPAddress | Where-Object {
        $_.IPAddress -notlike "fe80*" -and $_.IPAddress -notlike "127.*"
    } | ForEach-Object {
        "Interface Alias: $($_.InterfaceAlias), IP Address: $($_.IPAddress)"
    }

    if ($ipAddresses) {
        $ipAddresses | ForEach-Object { Write-Host $_ -ForegroundColor Green }
        return $ipAddresses
    } else {
        Write-Host "No IP address information found." -ForegroundColor Red
    }
    
    $script:report += $ipAddresses
    Write-Host "IP address retrieval completed." -ForegroundColor Green
}


# Function to check Internet connectivity
function Test-InternetConnectivity {
    Write-Host "Checking internet connectivity..." -ForegroundColor Yellow
    $pingTest = Test-Connection -ComputerName 8.8.8.8 -Count 4 -ErrorAction SilentlyContinue
    $connectivityMessage = ""

    if (-not $pingTest) {
        $connectivityMessage = "Device cannot reach the Internet (8.8.8.8)."
    } else {
        $packetLoss = (4 - $pingTest.Count) * 25
        if ($packetLoss -gt 0) {
            $connectivityMessage = "Detected $packetLoss% packet loss during ping to 8.8.8.8."
        } else {
            $connectivityMessage = "Device can reach the Internet (8.8.8.8) without packet loss."
        }
    }

    $script:report += $connectivityMessage
    Write-Host "Internet connectivity check completed." -ForegroundColor Green
}

function Perform-Traceroute {
    Write-Host "Conducting traceroute..." -ForegroundColor Yellow
    $traceOutput = tracert 8.8.8.8
    $tracerouteMessages = @("Traceroute to 8.8.8.8:")

    # Parse the tracert output to extract relevant lines
    $hops = $traceOutput | Where-Object { $_ -match "^\s*\d+\s+" } 

    foreach ($hop in $hops) {
        $tracerouteMessages += $hop.Trim()
    }

    $script:report += $tracerouteMessages
    Write-Host "Traceroute completed." -ForegroundColor Green
}

# Function to check DNS resolution for a domain
function Check-DNSResolution {
    Write-Host "Checking DNS resolution for google.com..." -ForegroundColor Yellow
    $dnsTest = Resolve-DnsName -Name google.com -ErrorAction SilentlyContinue
    $dnsMessage = ""

    if ($dnsTest) {
        $ipv4Addresses = $dnsTest | Where-Object { $_.QueryType -eq 'A' } | ForEach-Object { $_.IPAddress }
        $dnsMessage = "Device successfully resolved DNS for google.com to: $($ipv4Addresses -join ', ')"
    } else {
        $dnsMessage = "Failed to resolve DNS for google.com."
    }

    $script:report += $dnsMessage
    Write-Host "DNS resolution check completed." -ForegroundColor Green
}


# Call the functions
Check-NetworkConnection
Get-MacAddress
Get-IPAddressInfo
Test-InternetConnectivity
Perform-Traceroute
Check-DNSResolution

# Return the report for use in BasicTroubleshooting Script

return $script:report
}

