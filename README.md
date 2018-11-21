Kafka Connect Sandbox
===

I have been working alot lately with Kafka Connect (primarily S3 Connect) and need to quickly debug things locally without access to an AWS account, so this project sets up [Minio](https://minio.io/) and collection of Confluent Platform Docker images for easy testing. Other connectors were added later.

To get working, clone, run `cp .env.template .env`, then edit that file with the appropriate information.

I'm using `make` targets to run things... *TODO: Document what's available*

Other Prerequisites:  
 - `docker` && `docker-compose`
 - `make`
 - Confluent Platform `bin/` tools installed on the `PATH` - *TODO: Refactor to `docker run --rm` commands*

**References**

 - Setup Connectors: https://docs.confluent.io/current/connect/index.html
 - Local S3 (Minio) w/ Connect: https://blog.minio.io/journaling-kafka-messages-with-s3-connector-and-minio-83651a51045d
 - Using Kafka Connect for raw topic backups (Confluent S3 Connector doesn't preserve keys using `ByteArrayFormat`)
   - https://jobs.zalando.com/tech/blog/backing-up-kafka-zookeeper/index.html?gh_src=4n3gxh1
   - https://github.com/imduffy15/kafka-connect-s3
 - Produce Avro Data: https://github.com/confluentinc/examples/tree/master/kafka-clients/specific-avro-producer
