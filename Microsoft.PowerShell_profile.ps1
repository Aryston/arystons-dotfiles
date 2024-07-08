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
