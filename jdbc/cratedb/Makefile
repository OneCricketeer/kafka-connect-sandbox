CRATE_COMPOSE_FILE = jdbc/cratedb/crate-compose.yml

.PHONY: cratedb
cratedb: connect
	docker-compose -f $(CRATE_COMPOSE_FILE) -p $(COMPOSE_PROJECT_NAME) up -d
clean-cratedb:
	docker-compose -f $(CRATE_COMPOSE_FILE) -p $(COMPOSE_PROJECT_NAME) rm -fs

##########
# Sinks
##########



##########
# Sources
##########