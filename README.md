Kafka Connect Sandbox
===

I have been working alot lately with Kafka Connect (primarily S3 Connect) and need to quickly debug things locally without access to an AWS account, so this project sets up [Minio](https://minio.io/) and collection of Confluent Platform Docker images for easy testing. 

To get working, clone, run `cp .env.template .env`, then edit that file with the appropriate information. 

I'm using `make` targets to run things, but directly using `docker-compose` should work as well. 

**References**

 - https://docs.confluent.io/current/connect/index.html
 - https://blog.minio.io/journaling-kafka-messages-with-s3-connector-and-minio-83651a51045d
