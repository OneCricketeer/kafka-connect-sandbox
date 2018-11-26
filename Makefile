CONNECT_COMPOSE_FILE = connect-compose.yml

BOOTSTRAP ?= localhost:9092
ZKROOT ?= localhost:2181/kafka
SR ?= http://localhost:8081
CONNECT_URL ?= http://localhost:8083

PARTITIONS ?= 1
TOPIC ?= clicks

CONNECT_TOPIC_NAMESPACE ?= kafka-connect

CONNECT_HEADERS = -H Content-Type:application/json

# docker-network:
# 	docker network create kafka-backend
# 	docker network create kafka-frontend
# 	docker network create kafka-connect
# clean-docker-network:
# 	docker network rm kafka-backend
# 	docker network rm kafka-frontend
# 	docker network rm kafka-connect

.PHONY: kafka connect
kafka:
	docker-compose -f $(CONNECT_COMPOSE_FILE) up -d kafka
	@echo "Waiting for Kafka"
	@sleep 10
connect: kafka create-connect-topics-$(CONNECT_TOPIC_NAMESPACE)
	docker-compose -f $(CONNECT_COMPOSE_FILE) up -d kafka-connect kafka-connect-ui
clean-connect:
	docker-compose -f $(CONNECT_COMPOSE_FILE) stop && docker-compose -f $(CONNECT_COMPOSE_FILE) rm -f

list-topics:
	docker-compose -f $(CONNECT_COMPOSE_FILE) exec kafka \
	kafka-topics --zookeeper zookeeper:2181/kafka --list

consume-$(TOPIC):
	docker-compose -f $(CONNECT_COMPOSE_FILE) exec kafka \
	kafka-console-consumer --topic=$(TOPIC) \
	--bootstrap-server $(BOOTSTRAP) \
	--property print.key=true \
	--from-beginning

consume-avro-$(TOPIC):
	docker-compose -f $(CONNECT_COMPOSE_FILE) exec schema-registry \
	kafka-avro-console-consumer --topic=$(TOPIC) \
	--bootstrap-server $(BOOTSTRAP) \
	--property schema.registry.url=http://schema-registry:8081 \
	--property key-deserializer=org.apache.kafka.common.serialization.StringDeserializer \
	--property print.key=true \
	--from-beginning

create-topic-$(TOPIC):
	docker-compose -f $(CONNECT_COMPOSE_FILE) exec kafka \
	kafka-topics --create --topic $(TOPIC) \
	--zookeeper zookeeper:2181/kafka \
	--partitions $(PARTITIONS) --replication-factor=1

clean-topic-$(TOPIC):
	docker-compose -f $(CONNECT_COMPOSE_FILE) exec kafka \
	kafka-topics --zookeeper zookeeper:2181/kafka --delete --topic $(TOPIC)


get-connects:
	curl $(CONNECT_URL)/connectors

create-connect-topics-$(CONNECT_TOPIC_NAMESPACE):
	docker-compose -f $(CONNECT_COMPOSE_FILE) exec kafka bash -c \
	"kafka-topics --create --if-not-exists --zookeeper zookeeper:2181/kafka --topic $(CONNECT_TOPIC_NAMESPACE)_configs --replication-factor 1 --partitions 1 --config cleanup.policy=compact --disable-rack-aware \
	&& kafka-topics --create --if-not-exists --zookeeper zookeeper:2181/kafka --topic $(CONNECT_TOPIC_NAMESPACE)_offsets --replication-factor 1 --partitions 10 --config cleanup.policy=compact --disable-rack-aware \
	&& kafka-topics --create --if-not-exists --zookeeper zookeeper:2181/kafka --topic $(CONNECT_TOPIC_NAMESPACE)_status --replication-factor 1 --partitions 10 --config cleanup.policy=compact --disable-rack-aware"

clean-connect-topics-$(CONNECT_TOPIC_NAMESPACE):
	docker-compose -f $(CONNECT_COMPOSE_FILE) exec kafka bash -c \
	"kafka-topics --zookeeper zookeeper:2181/kafka --delete --topic $(CONNECT_TOPIC_NAMESPACE)_config
	&& kafka-topics --zookeeper zookeeper:2181/kafka --delete --topic $(CONNECT_TOPIC_NAMESPACE)_offsets
	&& kafka-topics --zookeeper zookeeper:2181/kafka --delete --topic $(CONNECT_TOPIC_NAMESPACE)_status"

clean-connector-$(CONNECTOR_NAME):
	@curl -XDELETE $(CONNECT_URL)/connectors/$(CONNECTOR_NAME)


schemas-restore:
	# export SCHEMA=$$(jq tostring LogLine.avsc)
	# curl -XPOST -d"{\"schema\":$$SCHEMA}" http://localhost:8081/subjects/$TOPIC-value/versions
	# curl -XPOST -H Content-Type:application/json -d'{"schema":"\"string\""}' http://localhost:8081/subjects/clicks-key/versions
	kafka-console-producer --broker-list $(BOOTSTRAP) --topic _schemas --property parse.key=true < schemas.txt

include s3-minio/Makefile
include jdbc/mssql/Makefile
