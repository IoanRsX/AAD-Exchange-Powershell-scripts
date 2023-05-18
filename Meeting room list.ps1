# Install and import the Exchange Online PowerShell module if you don't have it installed/imported already
Install-Module -Name ExchangeOnlineManagement -Force
Import-Module ExchangeOnlineManagement

# Connect to Exchange Online - make sure you have activated HelpDesk Admin role / Exchange Admin in AAD
Connect-ExchangeOnline

# Retrieve all meeting rooms
$meetingRooms = Get-ExoMailbox -RecipientTypeDetails RoomMailbox -ResultSize Unlimited

# Create an array to store the room information
$roomList = @()

# Iterate through each meeting room
foreach ($room in $meetingRooms) {
    $roomInfo = [PSCustomObject]@{
        DisplayName = $room.DisplayName
        UPN = $room.UserPrincipalName
            }

    $roomList += $roomInfo
}

# Export the room list to a CSV file
$roomList | Export-Csv -Path "c:\whatever\MeetingRooms.csv" -NoTypeInformation

# Disconnect from Exchange Online
Disconnect-ExchangeOnline
