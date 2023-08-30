# BasicTroubleshooting
PowerShell 7 Scripts to perform basic information gathering for support purposes (Windows).

This script is configured to gather hardware, driver, OS, network, and application information on the host machine, replicating many of the functions an L1 personnel would need to take to begin basic troubleshooting. Currently, the BasicTroubleshooting script also encapsulates some simple traceroute and ping functionality to test network connectivity and DNS server resolution.
This script will also attempt to create a C:\Scripts\ folder to store a sysinfo.txt with a timestamp, containing all of the troubleshooting information.

Future developments include more robust exception handling, a config file containing export methods and addresses, and a debug file to log any errors with implementation of the BasicTroubleshooting script.
