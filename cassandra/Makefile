CASSANDRA_COMPOSE_FILE = cassandra/cassandra-compose.yml

.PHONY: cassandra
cassandra: connect
	docker-compose -f $(CASSANDRA_COMPOSE_FILE) -p $(COMPOSE_PROJECT_NAME) up -d
clean-cassandra:
	docker-compose -f $(CASSANDRA_COMPOSE_FILE) -p $(COMPOSE_PROJECT_NAME) stop && docker-compose -f $(CASSANDRA_COMPOSE_FILE) -p $(COMPOSE_PROJECT_NAME) rm -f

##########
# Sinks
##########
sink-cassandra:
	curl -XPOST $(CONNECT_HEADERS) -d@sinks/cassandra.json $(CONNECT_URL)/connectors



##########
# Sources
##########
# src-cassandra:
#	curl -XPOST $(CONNECT_HEADERS) -d@sources/cassandra-cdc.json $(CONNECT_URL)/connectors
