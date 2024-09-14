#!/bin/bash

# Kafka bootstrap server address
bootstrap_server="localhost:9092"

# List of user names
declare -a users=(
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

# Loop through each user
for user in "${users[@]}"; do
    # Create a username by replacing spaces with dashes and converting to lowercase
    user_name=$(echo "$user" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    
    # Create ACL for creating topics with prefix
    ./kafka-acls.sh --bootstrap-server $bootstrap_server --add --allow-principal User:$user_name --operation Create --topic $user_name- --resource-pattern-type prefixed
    
    # Create ACL for producing to topics with prefix
    ./kafka-acls.sh --bootstrap-server $bootstrap_server --add --allow-principal User:$user_name --producer --topic $user_name- --resource-pattern-type prefixed
    
    # Create ACL for consuming from topics with prefix
    ./kafka-acls.sh --bootstrap-server $bootstrap_server --add --allow-principal User:$user_name --consumer --topic $user_name- --group '*' --resource-pattern-type prefixed
    
    # Create a default topic for each user
    ./kafka-topics.sh --bootstrap-server $bootstrap_server --create --topic $user_name-default --partitions 1 --replication-factor 1
done