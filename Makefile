BOOTSTRAP ?= localhost:9092
ZKROOT ?= localhost:2181/kafka
SR ?= http://localhost:8081
CONNECT_URL ?= http://localhost:8083

PARTITIONS ?= 1
TOPIC ?= clicks

BUCKET_NAME ?= example-kafka-backup-bucket
S3_SINK_CONNECTOR_NAME ?= example-topic-backup-minio
S3_SRC_CONNECTOR_NAME ?= example-topic-restore-minio

CONNECT_TOPIC_NAMESPACE ?= kafka-connect

.PHONY: s3 connect clean
connect: s3
	docker-compose up kafka-connect kafka-connect-ui
clean:
	docker-compose stop && docker-compose rm -f
	@#rm -rf ./data/$(BUCKET_NAME)/*
s3:
	docker-compose up -d minio

create-topic-$(TOPIC):
	kafka-topics --create --topic $(TOPIC) \
	--zookeeper $(ZKROOT) \
	--partitions $(PARTITIONS) --replication-factor=1

s3-sink:
	curl -XPOST -H Content-Type:application/json -d@sinks/s3-minio-binary-backup.json $(CONNECT_URL)/connectors
s3-sink-confluent:
	curl -XPOST -H Content-Type:application/json -d@sinks/s3-minio-confluent.json $(CONNECT_URL)/connectors

clean-s3-sink:
	curl -XDELETE $(CONNECT_URL)/connectors/$(S3_SINK_CONNECTOR_NAME)


consume-$(TOPIC):
	kafka-avro-console-consumer --topic=$(TOPIC) \
	--bootstrap-server $(BOOTSTRAP) \
	--property schema.registry.url=$(SR) \
	--property key-deserializer=org.apache.kafka.common.serialization.StringDeserializer \
	--property print.key=true \
	--from-beginning


s3-source:
	curl -XPOST -H Content-Type:application/json -d@sources/s3-minio.json $(CONNECT_URL)/connectors
clean-s3-source:
	curl -XDELETE $(CONNECT_URL)/connectors/$(S3_SRC_CONNECTOR_NAME)


list-topics:
	kafka-topics --zookeeper $(ZKROOT) --list

create-connect-topics-$(CONNECT_TOPIC_NAMESPACE):
	kafka-topics --create --zookeeper $(ZKROOT) --topic $(CONNECT_TOPIC_NAMESPACE)_configs --replication-factor 1 --partitions 1 --config cleanup.policy=compact --disable-rack-aware
	kafka-topics --create --zookeeper $(ZKROOT) --topic $(CONNECT_TOPIC_NAMESPACE)_offsets --replication-factor 1 --partitions 10 --config cleanup.policy=compact --disable-rack-aware
	kafka-topics --create --zookeeper $(ZKROOT) --topic $(CONNECT_TOPIC_NAMESPACE)_status --replication-factor 1 --partitions 10 --config cleanup.policy=compact --disable-rack-aware

clean-connect-topics-$(CONNECT_TOPIC_NAMESPACE):
	kafka-topics --zookeeper $(ZKROOT) --delete --topic $(CONNECT_TOPIC_NAMESPACE)_config
	kafka-topics --zookeeper $(ZKROOT) --delete --topic $(CONNECT_TOPIC_NAMESPACE)_offsets
	kafka-topics --zookeeper $(ZKROOT) --delete --topic $(CONNECT_TOPIC_NAMESPACE)_status

clean-topic-$(TOPIC):
	kafka-topics --zookeeper $(ZKROOT) --delete --topic $(TOPIC)

consume-schemas:
	kafka-console-consumer --topic _schemas \
	--bootstrap-server $(BOOTSTRAP) \
	--property print.key=true \
	--from-beginning

schemas-restore:
	# export SCHEMA=$$(jq tostring LogLine.avsc)
	# curl -XPOST -d"{\"schema\":$$SCHEMA}" http://localhost:8081/subjects/$TOPIC-value/versions
	# curl -XPOST -H Content-Type:application/json -d'{"schema":"\"string\""}' http://localhost:8081/subjects/clicks-key/versions
	kafka-console-producer --broker-list $(BOOTSTRAP) --topic _schemas --property parse.key=true < schemas.txt
