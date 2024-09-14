#!/bin/bash
# Author: Pieter Deconinck
#
# Input: none
# Output: List of users with passwords
#
# Purpose: This script adds a list of users to Kerberos
# For each user the script generates a 15 character password

# [ VARIABLES ] #

# Filename for the output of users and passwords
OUTPUT_FILENAME="users_passwords.txt"

# List of users to be added
USERS_LIST=(
    "Bryan Cranston"
    "Aaron Paul"
    "Anna Gunn"
    "Dean Norris"
    "Betsy Brandt"
    "Bob Odenkirk"
    "Rhea Seehorn"
    "Jonathan Banks"
    "Giancarlo Esposito"
    "Michael Mando"
)

# [ FUNCTIONS ] #

generate_username() {
    local name="$1"

    username=$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    echo "$username"
}

generate_password() {
    tr -dc A-Za-z0-9 </dev/urandom | head -c 15 ; echo ''
}

empty_output_file(){
    > "$OUTPUT_FILENAME"
}

log(){
    local content="$1"
    local date

    date=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[ $date ]: $content"
}

# [ MAIN ] #

main(){

    log "Emptying output file: ${OUTPUT_FILENAME}"
    empty_output_file

    log "Adding users to Kerberos"
    for user in "${USERS_LIST[@]}"; do

        log "Adding ${user}"
        username=$(generate_username "$user")
        password=$(generate_password)

        sudo kadmin.local -q "addprinc -pw $password $username" >> /dev/null
        echo "$username:$password" >> "$OUTPUT_FILENAME"
    done

    log "Script finished"
}


# [ EXECUTE MAIN ] #

main
