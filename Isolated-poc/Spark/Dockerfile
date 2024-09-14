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

# Set JAVA_HOME environment variable
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64

# Download and extract hadoop
RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz && \
    tar -xzf hadoop-3.3.6.tar.gz && \
    rm hadoop-3.3.6.tar.gz && \
    mv hadoop-3.3.6 hadoop