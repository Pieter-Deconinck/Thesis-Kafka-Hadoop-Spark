#!/bin/bash
# Author: Pieter Deconinck
#
# Input: none
# Output: List of removed users
#
# Purpose: This script removes a list of users from Kerberos

# [ VARIABLES ] #

# Filename for the output of removed users
OUTPUT_FILENAME="removed_users.txt"

# List of users to be removed
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

    log "Removing users from Kerberos"
    for user in "${USERS_LIST[@]}"; do

        log "Removing ${user}"
        username=$(generate_username "$user")

        if sudo kadmin.local -q "delprinc -force $username" >> /dev/null; then
            log "Successfully removed ${user}"
            echo "$username" >> "$OUTPUT_FILENAME"
        else
            log "Failed to remove ${user}"
        fi
    done

    log "Script finished"
}

# [ EXECUTE MAIN ] #

main