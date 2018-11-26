ELASTIC_COMPOSE_FILE = elastic/elastic-compose.yml

.PHONY: elastic
elastic: connect
	docker-compose -f $(ELASTIC_COMPOSE_FILE) up -d
clean-elastic:
	docker-compose -f $(ELASTIC_COMPOSE_FILE) stop && docker-compose -f $(ELASTIC_COMPOSE_FILE) rm -f

##########
# Sinks
##########
sink-elastic:
	curl -XPOST $(CONNECT_HEADERS) -d@sinks/elastic.json $(CONNECT_URL)/connectors