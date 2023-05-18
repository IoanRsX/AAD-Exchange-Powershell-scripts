$csvFilePath = "C:\whatever\list of users.csv"
$exportFilePath = "C:\whatever\list of devices.csv"

# Import CSV file and get email addresses
$csvData = Import-Csv -Path $csvFilePath
$emailAddresses = $csvData.Email

# Create an array to store export data
$exportData = @()

# Loop through email addresses and retrieve device information
foreach ($email in $emailAddresses) {
    # Get user object by email
    $user = Get-AzureADUser -Filter "UserPrincipalName eq '$email'"
    if ($user -ne $null) {
        # Get user device object by user object ID
        $devices = Get-AzureADUserRegisteredDevice -ObjectId $user.ObjectId
        if ($devices -ne $null) {
            foreach ($device in $devices) {
                # Get device object by device ID
                $deviceObj = Get-AzureADDevice -ObjectId $device.ObjectId
                # Add device information to export data array, including serial number
                $exportData += [PSCustomObject]@{
                    "User Email" = $email
                    "Device Name" = $device.DisplayName
                    "Device ID" = $device.DeviceId
                    "Serial Number" = $deviceObj.SerialNumber
                }
            }
        }
        else {
            # Add message to export data array indicating no allocated device
            $exportData += [PSCustomObject]@{
                "User Email" = $email
                "Device Name" = "User has no allocated device"
                "Device ID" = "N/A"
                "Serial Number" = "N/A"
            }
        }
    }
    else {
        Write-Warning "User with email address $email not found"
    }
}

# Export data to CSV file
$exportData | Export-Csv -Path $exportFilePath -NoTypeInformation
