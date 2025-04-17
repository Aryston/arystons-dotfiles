function Get-Uptime {
    param (
        [string]$ComputerName = $env:COMPUTERNAME
    )
    $uptimeInfo = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        $lastBootUpTime = (gcim Win32_OperatingSystem).LastBootUpTime
        $currentTime = Get-Date
        $uptimeSpan = $currentTime - $lastBootUpTime
        [PSCustomObject]@{
            LastBootUpTime = $lastBootUpTime
            Days = $uptimeSpan.Days
            Hours = $uptimeSpan.Hours
            Minutes = $uptimeSpan.Minutes
        }
    }

    $lastBootTimeFormatted = $uptimeInfo.LastBootUpTime.ToString("dd/MM/yyyy HH:mm:ss")
    Write-Output "Uptime for ${ComputerName}: $($uptimeInfo.Days) days, $($uptimeInfo.Hours) hours, $($uptimeInfo.Minutes) minutes"
    Write-Output "Last restart: $lastBootTimeFormatted"
}

# Create an alias 'uptime' for the Get-Uptime function
Set-Alias -Name uptime -Value Get-Uptime

function Get-SystemInfo {
    param (
        [string]$ComputerName = $null
    )

    # ScriptBlock to retrieve system information
    $sysInfoScriptBlock = {
        $osInfo = systeminfo | Select-String -Pattern "OS Name", "OS Version"
        $biosInfo = systeminfo | Select-String -Pattern "BIOS Version"
        $hardwareInfo = Get-WmiObject win32_systemenclosure | Select-Object Manufacturer, SerialNumber

        # Construct output as a string
        $output = @(
            $osInfo[0].Line
            $osInfo[1].Line
            $biosInfo.Line
            "Manufacturer: $($hardwareInfo.Manufacturer)"
            "SerialNumber: $($hardwareInfo.SerialNumber)"
        )
        $output -join "`n"
    }

    # Run the script block locally or remotely based on $ComputerName
    if ($ComputerName) {
        $result = Invoke-Command -ComputerName $ComputerName -ScriptBlock $sysInfoScriptBlock
    } else {
        $result = Invoke-Command -ScriptBlock $sysInfoScriptBlock
    }

    # Display the result
    Write-Output $result
}

# Save the function in your profile
Set-Alias -Name Get-SysInfo -Value Get-SystemInfo

function Get-ComputerName {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Username
    )

    $csvPath = "C:\Users\igor.jagec\OneDrive - Pentex Ltd\IT Team\UserComputers.csv"

    # Check if the CSV file exists
    if (-Not (Test-Path -Path $csvPath)) {
        Write-Error "CSV file not found at $csvPath"
        return
    }

    # Import the CSV data
    $userComputers = Import-Csv -Path $csvPath

    # Find the computer name for the given username
    $computer = $userComputers | Where-Object { $_.Username -ieq $Username }

    if ($computer) {
        return $computer.ComputerName
    } else {
        Write-Output "No computer found for username: $Username"
    }
}



net use S: "\\pentex.local\corpdata\FileShares\Pentex Shared" F0rzaM1lan /user:igor.jagec
