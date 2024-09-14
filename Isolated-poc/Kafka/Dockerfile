# Start from the rastasheep/ubuntu-sshd image
FROM rastasheep/ubuntu-sshd:18.04

# Install necessary packages including ping and ss
RUN apt-get update && apt-get install -y \
    wget \
    openjdk-11-jdk \
    tar \
    iputils-ping \
    iproute2 \
    curl \
    nmap \
    netcat \
    pv

# Download and extract Kafka
RUN wget https://dlcdn.apache.org/kafka/3.7.0/kafka_2.13-3.7.0.tgz && \
    tar -xzf kafka_2.13-3.7.0.tgz && \
    rm kafka_2.13-3.7.0.tgz && \
    mv kafka_2.13-3.7.0 kafka
