#!/bin/bash
# Author: Pieter Deconinck
#
# Input: none
# Output: none
#
# Purpose: This script installs and configures a client
# This script is not yet idempotent
# Required configuration files: krb5.conf
# 

# [ VARIABLES ] #

CONFIG_DIRECTORY="/vagrant/shared"  # Directory containing the configuration files
HOME_DIRECTORY="/home/vagrant" # User directory where to install Hadoop, Yarn and Spark
REALM="EXAMPLE.COM"  # Kerberos realm
KERBEROS_HOSTNAME="kerberos"  # Kerberos server hostname
HOSTNAME="client" # hostname

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
    echo "192.168.56.9 kerberos.example.com kerberos" | sudo tee -a /etc/hosts >> /dev/null
    echo "192.168.56.10 master.example.com master" | sudo tee -a /etc/hosts >> /dev/null
    echo "192.168.56.11 slave.example.com slave" | sudo tee -a /etc/hosts >> /dev/null

    log "Installing Required packages"

    # Preconfigure Kerberos settings to avoid interactive prompts
    echo "krb5-user krb5-config/default_realm string $REALM" | sudo debconf-set-selections
    echo "krb5-user krb5-config/admin_server string $KERBEROS_HOSTNAME" | sudo debconf-set-selections
    echo "krb5-user krb5-config/kerberos_servers string $KERBEROS_HOSTNAME" | sudo debconf-set-selections

    sudo apt install ssh pdsh openjdk-11-jdk-headless krb5-user -y

    log "Downloading and installing Kafka"
    cd $HOME_DIRECTORY
    wget https://dlcdn.apache.org/kafka/3.7.0/kafka_2.13-3.7.0.tgz && \
    tar -xzf kafka_2.13-3.7.0.tgz && \
    rm kafka_2.13-3.7.0.tgz && \
    mv kafka_2.13-3.7.0 kafka

    log "Downloading and installing hadoop"
    cd $HOME_DIRECTORY
    wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz && \
    tar -xzf hadoop-3.3.6.tar.gz && \
    rm hadoop-3.3.6.tar.gz && \
    mv hadoop-3.3.6 $HOME_DIRECTORY/hadoop

    log "Downloading and installing Spark"
    cd $HOME_DIRECTORY
    wget https://dlcdn.apache.org/spark/spark-3.5.1/spark-3.5.1-bin-hadoop3.tgz && \
    tar -xzf spark-3.5.1-bin-hadoop3.tgz && \
    rm spark-3.5.1-bin-hadoop3.tgz && \
    mv spark-3.5.1-bin-hadoop3/ spark
    
    log "Adding Kafka to PATH"
    export PATH=$PATH:$HOME_DIRECTORY/kafka/bin
    echo "export PATH=\$PATH:$HOME_DIRECTORY/kafka/bin" >> ~/.bashrc

    log "Adding Hadoop to PATH"
    export PATH=$PATH:$HOME_DIRECTORY/hadoop/sbin:$HOME_DIRECTORY/hadoop/bin
    echo "export PATH=\$PATH:$HOME_DIRECTORY/hadoop/sbin:$HOME_DIRECTORY/hadoop/bin" >> ~/.bashrc
    
    log "Adding Spark to PATH"
    export PATH=$PATH:$HOME_DIRECTORY/spark/bin
    echo "export PATH=\$PATH:$HOME_DIRECTORY/spark/bin" >> ~/.bashrc

    log "Configuring Kerberos"
    sudo cp "$CONFIG_DIRECTORY/krb5.conf" /etc/krb5.conf 

    log "Setting hostname"
    sudo hostnamectl set-hostname "$HOSTNAME.$REALM"

    log "SCRIPT FINISHED"
}

main