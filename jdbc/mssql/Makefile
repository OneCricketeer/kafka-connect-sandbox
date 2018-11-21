MSSQL_COMPOSE_FILE = jdbc/mssql/mssql-compose.yml

.PHONY: mssql
mssql: connect
	docker-compose -f $(MSSQL_COMPOSE_FILE) up -d
clean-mssql:
	docker-compose -f $(MSSQL_COMPOSE_FILE) stop && docker-compose -f $(MSSQL_COMPOSE_FILE) rm -f

##########
# Sinks
##########



##########
# Sources
##########
src-mssql:
	curl -XPOST $(CONNECT_HEADERS) -d@sources/mssql.json $(CONNECT_URL)/connectors
