# Install AzureAD module if not already installed
if (-not (Get-Module -ListAvailable -Name AzureAD)) {
    Install-Module -Name AzureAD -Force
}

# Import the AzureAD module
Import-Module AzureAD

# Authenticate to Azure AD (sign in with your admin credentials, remember to grant yourself HelpDesk Admin or Exchange Admin or whatever)
Connect-AzureAD

# Specify the group name or object ID - it's hardcoded, couldn't be bothered with a prompt
$groupName = "Whatever group"

# Get the group object - change filtering if you're using ObjectID
$group = Get-AzureADGroup -Filter "DisplayName eq '$groupName'"

# Recursive function to get all group members 
function Get-GroupMembersRecursively {
    param (                                #Need to differentiate between results if they are "User" objects or "Group" objects
        [Parameter(Mandatory = $true)]
        [Microsoft.Open.AzureAD.Model.Group] $Group,
        [Parameter(Mandatory = $false)]
        [Microsoft.Open.AzureAD.Model.User[]] $Members = @()
    )

    # Get direct group members 
    $directMembers = Get-AzureADGroupMember -ObjectId $Group.ObjectId | Where-Object { $_.ObjectType -eq "User" }
    $Members += $directMembers

    # Get nested groups and their members recursively 
    $nestedGroups = Get-AzureADGroupMember -ObjectId $Group.ObjectId | Where-Object { $_.ObjectType -eq "Group" }
    foreach ($nestedGroup in $nestedGroups) {
        $nestedGroupObj = Get-AzureADGroup -ObjectId $nestedGroup.ObjectId
        $Members = Get-GroupMembersRecursively -Group $nestedGroupObj -Members $Members
    }

    return $Members
}

# Get all group members recursively using the function we created above
$allMembers = Get-GroupMembersRecursively -Group $group

# Prepare the output data
$outputData = foreach ($member in $allMembers) {
    $user = Get-AzureADUser -ObjectId $member.ObjectId
    [PSCustomObject]@{
        FirstName    = $user.GivenName
        LastName     = $user.Surname
        EmailAddress = $user.Mail
    }
}

# Save the output data to a CSV file
$outputData | Export-Csv -Path "C:\whatever\GroupMembers.csv" -NoTypeInformation

# Disconnect from Azure AD
Disconnect-AzureAD

Write-Host "Group members exported to GroupMembers.csv"