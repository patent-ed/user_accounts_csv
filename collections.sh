#!/bin/bash

# ##########
# macos bash script to list detailed user account option information in a csv table format that includes headings for: User id number, group, account name, full name, login shell, home directory location, uuid, Account Aliases, local or mobile account status, sysadminctl -secureTokenStatus, active directory account status for all accounts output to a file in /Users/Shared/ the relevant time_datestamp_account.csv file name 

# Get current date and time
current_date=$(date +"%Y-%m-%d_%H-%M-%S")

# Define the output file path and name
output_file="/Users/Shared/${current_date}_account.csv"

# Write the CSV headers
echo "User ID,Group,Account Name,Full Name,Login Shell,Home Directory,UUID,Account Aliases,Local or Mobile,Secure Token Status,Active Directory Status" > "$output_file"

# Iterate through all user accounts
for user in $(dscl . list /Users | grep -v "^_"); do
  # Get user account details
  user_id=$(dscl . -read /Users/$user UniqueID | awk '{print $2}')
  group=$(id -gn $user)
  full_name=$(dscl . -read /Users/$user RealName | tail -1 | sed 's/^ *//')
  login_shell=$(dscl . -read /Users/$user UserShell | awk '{print $2}')
  home_directory=$(dscl . -read /Users/$user NFSHomeDirectory | awk '{print $2}')
  uuid=$(dscl . -read /Users/$user GeneratedUID | awk '{print $2}')
  aliases=$(dscl . -read /Users/$user RecordAlias | sed -e 's/RecordAlias: //')
  account_type="Local" # Set to "Local" by default
  secure_token_status=$(sysadminctl -secureTokenStatus $user 2>&1 | awk -F': ' '{print $1}')
  active_directory_status="Not Active Directory Account" # Set to "Not Active Directory Account" by default

  # Check if the user is a mobile account
  if [[ $(dscl . -read /Users/$user OriginalNodeName 2>/dev/null) ]]; then
    account_type="Mobile"
  fi

  # Write user account details to the output file
  echo "\"$user_id\",\"$group\",\"$user\",\"$full_name\",\"$login_shell\",\"$home_directory\",\"$uuid\",\"$aliases\",\"$account_type\",\"$secure_token_status\",\"$active_directory_status\"" >> "$output_file"
done
