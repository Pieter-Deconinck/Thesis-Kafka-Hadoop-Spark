sudo apt update -y
sudo apt install ssh openjdk-11-jdk-headless krb5-user -y

wget https://dlcdn.apache.org/kafka/3.7.0/kafka_2.13-3.7.0.tgz && \
    tar -xzf kafka_2.13-3.7.0.tgz && \
    rm kafka_2.13-3.7.0.tgz && \
    mv kafka_2.13-3.7.0 kafka

nano /home/vagrant/kafka/config/server.properties
nano /etc/krb5.conf
nano /home/vagrant/kafka/kafka_server_jaas.conf
nano /home/vagrant/kafka/start-kafka.sh
chmod +x /home/vagrant/kafka/start-kafka.sh

sudo nano /etc/hosts