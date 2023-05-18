# Connect to Exchange Online
$ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $UserCredential -Authentication "Basic" -AllowRedirection
Import-PSSession $ExchangeSession -DisableNameChecking

# Get all meeting rooms
$MeetingRooms = Get-Mailbox -RecipientTypeDetails RoomMailbox -ResultSize Unlimited

# Initialize an empty array to store the results
$Results = @()

# Loop through each meeting room
foreach ($Room in $MeetingRooms) {

    # Get the list of users with permissions on the meeting room
    $Permissions = Get-MailboxPermission -Identity $Room.DistinguishedName | Where-Object {$_.User -ne "NT AUTHORITY\SELF" -and $_.User -notlike "S-*"}

    # Loop through each permission and add it to the results array
    foreach ($Permission in $Permissions) {
        $Result = New-Object PSObject -Property @{
            "Meeting Room" = $Room.Name
            "User" = $Permission.User
            "Access Rights" = $Permission.AccessRights
        }
        $Results += $Result
    }
}