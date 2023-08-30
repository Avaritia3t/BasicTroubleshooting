# BasicTroubleshooting
PowerShell 7 Scripts to perform basic information gathering for support purposes (Windows).

The main script, BasicTroubleshooting, is configured to gather hardware, driver, OS, network, and application information on the host machine, replicating many of the functions an L1 personnel would need to take to begin basic troubleshooting. It accomplishes this by incorporating several smaller scripts that each handle one of these tasks. These are also uploaded in this directory. The BasicTroubleshooting script should be run as an administrator, and will attempt to execute each of the child scripts in turn. This script will also attempt to create a C:\Scripts\ folder to store a sysinfo.txt with a timestamp, containing all of the troubleshooting information.

Network Troubleshooting: Currently, the NetworkTroubleshooting script checks the current network connection for SSID and ethernet/Wi-Fi status. MAC address and IP address are gathered. Finally, the script encapsulates some simple traceroute and ping functionality to test network connectivity and DNS server resolution.

Session Troubleshooting: GetSessionInfo requires privilege elevation, and gathers current username, last boot time, last login time, and information on the OS build and update status. The 10 most recent updates are displayed, but the total list of installed updates is exported to the sysinfo file.

Hardware Troubleshooting: GetHardwareInfo gathers hardware make and model, processor info, BIOS version, Memory info, disk info (free/size), and GPU/NIC info as well. Battery status is retrieved if available.

Application Troubleshooting: This gathers a list of installed applications, as well as their current build versions. Also returns a list of installed drivers and corresponding versions, and returns a list of active services running on the machine at the time of diagnosis. Handy for an immediate 'snapshot!' tool that end users can press to capture information before any system changes.

The script is currently fairly lightweight, but can be built all around. Future developments include more robust exception handling, a config file containing export methods and addresses, and a debug file to log any errors with implementation of the BasicTroubleshooting script.
