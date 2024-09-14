#!/bin/bash
# Author: Pieter Deconinck
#
# Input: none
# Output: none
#
# Purpose: This script adds a list of users to Hadoop distributed file system

# [ VARIABLES ] #

# Filename for the output of added users
OUTPUT_FILENAME="users.txt"

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

# Hadoob distributed file system path
HDFS_PATH="/home/vagrant/hadoop/bin/hdfs"

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

create_user_directory(){
    hdfs dfs -mkdir /user
}

check_hdfs(){
    $HDFS_PATH dfsadmin -report > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        log "HDFS is not available. Exiting."
        exit 1
    fi
}

# [ MAIN ] #

main(){
    log "Authenticate using kerberos"
    kinit -kt /home/vagrant/hadoop/etc/hadoop/hdfs.master.keytab hdfs/master.example.com@EXAMPLE.COM

    log "Checking if HDFS is available"
    check_hdfs

    log "Emptying output file: ${OUTPUT_FILENAME}"
    empty_output_file

    log "Creating user directory on HDFS"
    create_user_directory

    log "Adding users to Hadoop"
    for user in "${USERS_LIST[@]}"; do
        log "Adding ${user}"
        username=$(generate_username "$user")

        if hdfs dfs -mkdir /user/$username/tmp; then
            hdfs dfs -chown $username:$username /user/$username/tmp
            hdfs dfs -chmod 700 /user/$username/tmp
        else
            log "Failed to add ${username} to HDFS"
        fi

        if hdfs dfs -mkdir /user/$username; then
            hdfs dfs -chown $username:$username /user/$username
            hdfs dfs -chmod 700 /user/$username
            echo "$username" >> "$OUTPUT_FILENAME"
            log "Successfully added ${username} to HDFS"
        else
            log "Failed to add ${username} to HDFS"
        fi
        
    done

    log "Script finished"
}

# [ EXECUTE MAIN ] #

main