# Script written for PowerShell 7

function Get-HardwareInfo {
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Error "This script requires PowerShell 7 or higher."
        exit
    }

    # Initialize the report array
    $hardwareReport = @()

    # Function to get hardware make and model
    function Get-SystemMakeModel {
        Write-Host "Retrieving system make and model..." -ForegroundColor Yellow
        $systemInfo = Get-CimInstance -ClassName Win32_ComputerSystem
        $makeModelMessage = "System Manufacturer: $($systemInfo.Manufacturer), Model: $($systemInfo.Model)"
        $hardwareReport += $makeModelMessage
        Write-Host $makeModelMessage
        Write-Host "System make and model retrieval completed." -ForegroundColor Green
    }

    # Function to get processor information
    function Get-ProcessorInfo {
        Write-Host "Retrieving processor information..." -ForegroundColor Yellow
        $processor = Get-CimInstance -ClassName Win32_Processor
        $processorMessage = "Processor: $($processor.Name)"
        $hardwareReport += $processorMessage
        Write-Host $processorMessage
        Write-Host "Processor information retrieval completed." -ForegroundColor Green
    }

    # Function to get BIOS version
    function Get-BiosVersion {
        Write-Host "Retrieving BIOS version..." -ForegroundColor Yellow
        $bios = Get-CimInstance -ClassName Win32_BIOS
        $biosMessage = "BIOS Version: $($bios.SMBIOSBIOSVersion)"
        $hardwareReport += $biosMessage
        Write-Host $biosMessage
        Write-Host "BIOS version retrieval completed." -ForegroundColor Green
    }

    # Function to get physical memory information
    function Get-MemoryInfo {
        Write-Host "Retrieving memory information..." -ForegroundColor Yellow
        $memory = Get-CimInstance -ClassName Win32_PhysicalMemory
        foreach ($mem in $memory) {
            $memoryMessage = "Memory Stick Capacity: $($mem.Capacity / 1GB)GB, Speed: $($mem.Speed)MHz, Manufacturer: $($mem.Manufacturer)"
            $hardwareReport += $memoryMessage
            Write-Host $memoryMessage
        }
        Write-Host "Memory information retrieval completed." -ForegroundColor Green
    }

    # Function to get disk drive information
    function Get-DiskInfo {
        Write-Host "Retrieving disk drive information..." -ForegroundColor Yellow
        $disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3"
        foreach ($disk in $disks) {
            $diskMessage = "Disk: $($disk.DeviceID), Size: $($disk.Size / 1GB)GB, Free Space: $($disk.FreeSpace / 1GB)GB"
            $hardwareReport += $diskMessage
            Write-Host $diskMessage
        }
        Write-Host "Disk drive information retrieval completed." -ForegroundColor Green
    }

    # Function to get graphics card information
    function Get-GraphicsInfo {
        Write-Host "Retrieving graphics card information..." -ForegroundColor Yellow
        $graphics = Get-CimInstance -ClassName Win32_VideoController
        foreach ($card in $graphics) {
            $graphicsMessage = "Graphics Card: $($card.Name), Memory: $($card.AdapterRAM / 1MB)MB"
            $hardwareReport += $graphicsMessage
            Write-Host $graphicsMessage
        }
        Write-Host "Graphics card information retrieval completed." -ForegroundColor Green
    }

    # Function to get network adapter information
    function Get-NetworkAdapterInfo {
        Write-Host "Retrieving network adapter information..." -ForegroundColor Yellow
        $adapters = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }
        foreach ($adapter in $adapters) {
            $adapterMessage = "Network Adapter: $($adapter.Description), IP Address: $($adapter.IPAddress -join ', ')"
            $hardwareReport += $adapterMessage
            Write-Host $adapterMessage
        }
        Write-Host "Network adapter information retrieval completed." -ForegroundColor Green
    }

    # Function to get battery information
    function Get-BatteryInfo {
        Write-Host "Retrieving battery information..." -ForegroundColor Yellow
        $battery = Get-CimInstance -ClassName Win32_Battery
        if ($battery) {
            $batteryMessage = "Battery Status: $($battery.Status), Estimated Charge Remaining: $($battery.EstimatedChargeRemaining)%"
            $hardwareReport += $batteryMessage
            Write-Host $batteryMessage
        } else {
            Write-Host "No battery detected on this device." -ForegroundColor Cyan
        }
        Write-Host "Battery information retrieval completed." -ForegroundColor Green
    }

    # Call the functions
    Get-SystemMakeModel
    Get-ProcessorInfo
    Get-BiosVersion
    Get-MemoryInfo
    Get-DiskInfo
    Get-GraphicsInfo
    Get-NetworkAdapterInfo
    Get-BatteryInfo

    # Return the report for further use
    return $hardwareReport
}