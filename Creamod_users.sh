#!/bin/bash

# Define the CSV file path

csv_file="users.csv"

create_user() {
    local username="$1"
    local password="<agregar password>" #password por defecto para los nuevos usuarios (se debe solicitar al usuario modificarlo).
    local admin_role="$2"
    local cli_permissions="$3"
    local partition="$4"

    # Create the user on BIG-IP
    echo "Creando usuario -> tmsh create auth user $username partition-access add {$partition { role "$admin_role" }} shell $cli_permissions password $password"
    tmsh create auth user $username partition-access add { $partition { role $admin_role } } shell $cli_permissions password $password
    echo "Created user: $username"
}

modify_user() {
    local username="$1"
    local admin_role="$2"
    local cli_permissions="$3"
    local partition="$4"
     echo " Modificando Usuario -> modify auth user $username partition-access replace-all-with { $partition { role $admin_role } } shell $cli_permissions"
    # Modify the user properties on BIG-IP
    tmsh modify auth user $username partition-access replace-all-with { $partition { role $admin_role }} shell $cli_permissions
    echo "Modified user: $username"
}

# Loop through the CSV file

while IFS=";" read -r Username admin_role cli_permissions partition; do

        echo $Username $admin_role $cli_permissions $partition
    # Validate if the user already exists on BIG-IP
        if tmsh list auth user $Username > /dev/null 2>&1; then
            # User exists, modify properties
            
            modify_user $Username $admin_role $cli_permissions $partition
        else
            # User doesn't exist, create new user
            echo "$Username $admin_role $cli_permissions $partition"
            
            create_user $Username $admin_role $cli_permissions $partition
        fi


done < "$csv_file"
