#!/bin/bash
# Author: Pieter Deconinck
#
# Input: none
# Output: none
#
# Purpose: This script installs and configures a master server (hdfs namenode, yarn resourcemanager)
# This script is not yet idempotent
# Required configuration files:
# hadoop-env.sh, core-site.xml, hdfs-site.xml, yarn-site.xml, workers, hdfs.master.keytab, yarn.master.keytab, id_rsa.pub

# [ VARIABLES ] #

CONFIG_DIRECTORY="/vagrant/shared"  # Directory containing the configuration files
HOME_DIRECTORY="/home/vagrant" # User directory where to install Hadoop, Yarn and Spark
REALM="EXAMPLE.COM"  # Kerberos realm
KERBEROS_HOSTNAME="kerberos"  # Kerberos server hostname
HOSTNAME="master" # hostname

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

    log "Downloading and installing hadoop"
    cd $HOME_DIRECTORY
    wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz && \
    tar -xzf hadoop-3.3.6.tar.gz && \
    rm hadoop-3.3.6.tar.gz && \
    mv hadoop-3.3.6 $HOME_DIRECTORY/hadoop

    log "Configuring Hadoop"
    sudo cp "$CONFIG_DIRECTORY/hadoop-env.sh"  $HOME_DIRECTORY/hadoop/etc/hadoop/hadoop-env.sh
    sudo cp "$CONFIG_DIRECTORY/core-site.xml"  $HOME_DIRECTORY/hadoop/etc/hadoop/core-site.xml
    sudo cp "$CONFIG_DIRECTORY/hdfs-site.xml"  $HOME_DIRECTORY/hadoop/etc/hadoop/hdfs-site.xml
    sudo cp "$CONFIG_DIRECTORY/yarn-site.xml"  $HOME_DIRECTORY/hadoop/etc/hadoop/yarn-site.xml
    sudo cp "$CONFIG_DIRECTORY/workers"  $HOME_DIRECTORY/hadoop/etc/hadoop/workers

    sudo cp "$CONFIG_DIRECTORY/hdfs.master.keytab"  $HOME_DIRECTORY/hadoop/etc/hadoop/hdfs.master.keytab
    sudo cp "$CONFIG_DIRECTORY/yarn.master.keytab"  $HOME_DIRECTORY/hadoop/etc/hadoop/yarn.master.keytab
    sudo chmod 0600 $HOME_DIRECTORY/hadoop/etc/hadoop/hdfs.master.keytab
    sudo chmod 0600 $HOME_DIRECTORY/hadoop/etc/hadoop/yarn.master.keytab
    sudo chown vagrant:vagrant $HOME_DIRECTORY/hadoop/etc/hadoop/hdfs.master.keytab
    sudo chown vagrant:vagrant $HOME_DIRECTORY/hadoop/etc/hadoop/yarn.master.keytab

    ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    chmod 0600 ~/.ssh/authorized_keys

    sudo mkdir -p $HOME_DIRECTORY/hadoop/dfs/name
    sudo mkdir -p $HOME_DIRECTORY/hadoop/dfs/data
    sudo chown -R vagrant:vagrant $HOME_DIRECTORY/hadoop/dfs

    log "Adding Hadoop to PATH"
    export PATH=$PATH:$HOME_DIRECTORY/hadoop/sbin:$HOME_DIRECTORY/hadoop/bin
    echo "export PATH=\$PATH:$HOME_DIRECTORY/hadoop/sbin:$HOME_DIRECTORY/hadoop/bin" >> ~/.bashrc

    log "Configuring Kerberos"
    sudo cp "$CONFIG_DIRECTORY/krb5.conf" /etc/krb5.conf 

    log "Adding kerberos public key to authorized keys"
    cat "$CONFIG_DIRECTORY/id_rsa.pub" >> ~/.ssh/authorized_keys

    log "Setting hostname"
    sudo hostnamectl set-hostname "$HOSTNAME.$REALM"

    # log "Starting namenode"
    # hdfs namenode -format -force -nonInteractive

    # log "Starting resourcemanager"
    # yarn --daemon start resourcemanager

    log "SCRIPT FINISHED"
    log "Run source ~/.bashrc to refresh the shell"
    log "Afterwards you can start the namenode and resourcemanger"
    log "hdfs namenode -format"
    log "hdfs --daemon start namenode"
    log "yarn --daemon start resourcemanager"
    log "if the namenode or resourcemanger gives an error try scp to transfer over the keytab files"
    log "scp /etc/krb5kdc/keytabs/hdfs.master.keytab vagrant@master.example.com:/home/vagrant/hadoop/etc/hadoop/hdfs.master.keytab"
}

main





echo 'export PATH=$PATH:/home/vagrant/hadoop/sbin:/home/vagrant/hadoop/bin' >> ~/.bashrc
