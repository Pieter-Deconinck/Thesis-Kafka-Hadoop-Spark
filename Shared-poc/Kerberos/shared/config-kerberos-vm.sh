#!/bin/bash
# Author: Pieter Deconinck
#
# Input: none
# Output: none
#
# Purpose: This script installs and configures a kerberos server
# This script is not yet idempotent
# Required configuration files:
# kadm5.acl, kdc.conf, krb5.conf

# [ VARIABLES ] #

CONFIG_DIRECTORY="/vagrant/shared"  # Directory containing the configuration files
PASSWORD="Pieter2024"  # Password for Kerberos
REALM="EXAMPLE.COM"  # Kerberos realm
HOSTNAME="kerberos"  # Kerberos server hostname

# [ FUNCTIONS ] #

log(){
    local content="$1"
    local date

    date=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[ $date ]: $content"
}

# [ MAIN ] #

main(){
    log "Updating apt"
    export DEBIAN_FRONTEND=noninteractive
    sudo sed -i "s/#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf

    sudo apt update -y 

    log "Setting hosts"
    echo "192.168.56.8 kafka.example.com kafka" | sudo tee -a /etc/hosts >> /dev/null
    echo "192.168.56.9 kerberos.example.com master" | sudo tee -a /etc/hosts >> /dev/null
    echo "192.168.56.10 master.example.com master" | sudo tee -a /etc/hosts >> /dev/null
    echo "192.168.56.11 slave.example.com slave" | sudo tee -a /etc/hosts >> /dev/null

    log "Installing Kerberos"
    # Preconfigure Kerberos settings to avoid interactive prompts
    echo "krb5-kdc krb5-config/default_realm string $REALM" | sudo debconf-set-selections
    echo "krb5-kdc krb5-config/admin_server string $HOSTNAME" | sudo debconf-set-selections
    echo "krb5-kdc krb5-config/kerberos_servers string $HOSTNAME" | sudo debconf-set-selections
    echo "krb5-admin-server krb5-admin-server/newrealm note" | sudo debconf-set-selections

    sudo apt install krb5-kdc krb5-admin-server -y 

    log "Adding new kerberos realm and setting password"
    { echo "$PASSWORD"; echo "$PASSWORD"; } | sudo krb5_newrealm

    log "Configuring Kerberos"
    sudo cp "$CONFIG_DIRECTORY/krb5.conf" /etc/krb5.conf
    sudo cp "$CONFIG_DIRECTORY/kdc.conf" /etc/krb5kdc/kdc.conf  
    sudo cp "$CONFIG_DIRECTORY/kadm5.acl" /etc/krb5kdc/kadm5.acl

    log "Starting and enabling Kerberos"
    sudo systemctl enable --now krb5-kdc
    sudo systemctl enable --now krb5-admin-server

    log "Creating keytabs directory"
    sudo mkdir -p /etc/krb5kdc/keytabs

    log "Creating service principals and keytabs"

    # Creating admin principal
    sudo kadmin.local -q "addprinc -pw $PASSWORD admin/admin"
    sudo kadmin.local -q "ktadd -k /etc/krb5kdc/kadm5.keytab admin/admin@$REALM"

    # Creating service principals and their keytabs
    for service in hdfs yarn; do
        for host in master slave; do
            principal="$service/$host.$REALM@$REALM"
            keytab="/etc/krb5kdc/keytabs/$service.$host.keytab"

            sudo kadmin.local -q "addprinc -randkey $principal"
            sudo kadmin.local -q "ktadd -k $keytab $principal"
        done
    done

    # Creating Kafka principal and keytab
    sudo kadmin.local -q "addprinc -randkey kafka/kafka.$REALM@$REALM"
    sudo kadmin.local -q "ktadd -k /etc/krb5kdc/keytabs/kafka.keytab kafka/kafka.$REALM@$REALM"

    log "Generate ssh key"
    ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa

    log "Setting hostname"
    sudo hostnamectl set-hostname "$HOSTNAME.$REALM"

    log "Script finished"
}

main
