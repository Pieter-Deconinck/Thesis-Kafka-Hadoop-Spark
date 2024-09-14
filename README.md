# Thesis: Efficient, Secure, and Scalable Implementation of Hadoop, Spark, and Kafka

## Overview

This repository contains all the code, configurations, and proof-of-concepts developed as part of my bachelor's thesis project at [Hogeschool Gent (HOGENT)](https://www.hogent.be/en/). The focus of the thesis is on implementing an efficient, secure, scalable, reproducible, and loggable infrastructure for Hadoop, Spark, and Kafka within the [Virtual IT Company (VIC)](https://vichogent.be/) datacenter at HOGENT.

The goal of this project is to shift the installation and management of these tools from individual student laptops to a centralized environment in the VIC datacenter. This would result in a more efficient use of time during lessons and exams, offering a real-world infrastructure experience for students.

## Contents

The repository is structured as follows:

- **`Isolated-poc/`**: Contains proof-of-concept implementations of isolated environments for:
  - `Kafka`: Dockerfiles and configuration for a standalone Kafka instance.
  - `Spark`: Dockerfiles and configuration for a standalone Spark instance.
  - `Hadoop`: Dockerfiles and configuration for a standalone Hadoop instance.

- **`Shared-poc/`**: Contains proof-of-concept implementations for a shared environment where multiple users can access:
  - `Hadoop-Spark-Master/`: Master node configuration for Hadoop and Spark in a shared environment.
  - `Hadoop-Spark-Slave/`: Slave node configuration for the shared environment.
  - `Kerberos/`: Setup for Kerberos authentication in the shared environment.
  - `Kafka/`: node configuration for Kafka in a shared environment.
  - `Client/`: Setup for client machine in the shared environment.

- **`LICENSE`**: Licensing information for this project.
- **`README.md`**: You're reading it!

## Technologies Used

- **Apache Kafka**: A distributed event streaming platform capable of handling high-throughput data.
- **Apache Hadoop**: An open-source software framework used for distributed storage and processing of large data sets.
- **Apache Spark**: A unified analytics engine for large-scale data processing.
- **Docker**: Used for containerization of the environments.
- **Kubernetes**: For orchestration of the containers in isolated and shared environments.
- **Kerberos**: For authentication within the shared environments.

## Author

Pieter Deconinck [LinkedIn](https://www.linkedin.com/in/pieter-deconinck-/?originalSubdomain=be)  
Bachelor of Applied Informatics, System & Network Administrator  
[Hogeschool Gent (HOGENT)](https://www.hogent.be/en/)  
[Virtual IT Company (VIC)](https://vichogent.be/)  

## Project Supervisors

- **Martijn Saelens** (Promoter)
- **Stijn Lievens** (Co-promoter)

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for more details.