#!/bin/bash

export KAFKA_OPTS="-Djava.security.auth.login.config=/home/vagrant/kafka/kafka_server_jaas.conf"
bin/kafka-server-start.sh config/kraft/server.properties
