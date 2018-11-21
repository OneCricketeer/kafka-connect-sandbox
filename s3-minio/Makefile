MINIO_COMPOSE_FILE = s3-minio/minio-compose.yml

BUCKET_NAME ?= datalake

.PHONY: s3-minio
s3-minio: connect
	docker-compose -f $(MINIO_COMPOSE_FILE) up -d
clean-s3-minio:
	docker-compose -f $(MINIO_COMPOSE_FILE) stop && docker-compose -f $(MINIO_COMPOSE_FILE) rm -f
	@#rm -rf ../minio-data/$(BUCKET_NAME)/*

##########
# Sinks
##########
sink-s3-binary:
	curl -XPOST $(CONNECT_HEADERS) -d@sinks/s3-minio-binary-backup.json $(CONNECT_URL)/connectors
sink-s3-avro:
	curl -XPOST $(CONNECT_HEADERS) -d@sinks/s3-minio-confluent.json $(CONNECT_URL)/connectors

##########
# Sources
##########
src-s3-binary:
	curl -XPOST $(CONNECT_HEADERS) -d@sources/s3-minio-binary-backup.json $(CONNECT_URL)/connectors
