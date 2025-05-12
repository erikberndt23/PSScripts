        # Import the membership list
        $users = Import-Csv "C:\path\to\users.csv"

        # Loop through each user in the CSV file
        foreach ($user in $users) {
            # Add the user to the AD group
            Add-ADGroupMember -Identity "YourGroupName" -Members $user.SamAccountName
        }