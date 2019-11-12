#doitlive prompt: damoekri
#doitlive speed: 2
#doitlive commentecho: true

docker-compose up -d

# Create a topic
# 
# kafka-topics --create --topic topic-a \
#  --bootstrap-server kafka-a:9092 \
#  --partitions=1 --replication-factor=1
#doitlive speed: 100000000
docker-compose exec kafka-connect bash -c "kafka-topics --create --topic topic-a --bootstrap-server kafka-a:9092 --partitions=1 --replication-factor=1"


# Produce data to simulate pre-existing topic data that will be replicated:
# 
# /scripts/0_Produce_Records_v1.sh kafka-a:9092 topic-a http://schema-registry-a:8081
docker-compose exec kafka-connect bash -c "/scripts/0_Produce_Records_v1.sh kafka-a:9092 topic-a http://schema-registry-a:8081"


# Replicate the data by posting a Kafka Connect configuration to its API.
# 
# /scripts/1_POST-replicator.sh
docker-compose exec kafka-connect bash -c "/scripts/1_POST-replicator.sh"


# Verify that the topic was created in the destination cluster 
# 
# kafka-topics --list --bootstrap-server kafka-b:9092
docker-compose exec kafka-connect bash -c "kafka-topics --list --bootstrap-server kafka-b:9092"


# Now that the topic has been replicated, try to consume the data
#
# kafka-avro-console-consumer \
#  --bootstrap-server kafka-b:9092 \
#  --topic topic-a.replica \
#  --property schema.registry.url=http://schema-registry-b:8081 \
#  --from-beginning

docker-compose exec kafka-connect bash -c "kafka-avro-console-consumer --bootstrap-server kafka-b:9092 --topic topic-a.replica --property schema.registry.url=http://schema-registry-b:8081 --from-beginning"

# This Schema not found error is expected when Kafka Connect is configured with ByteArrayConverter rather than AvroConverter because there is no configuration to reference Schema Registry B. Schema Registry B has no subjects, and therefore no schemas, as shown when contacting its API: 
# 
# curl http://schema-registry-b:8081/subjects
docker-compose exec kafka-connect bash -c "curl -w'\n' http://schema-registry-b:8081/subjects"

# Update the connector config to include the transform.

# In order for Replicator to know how to transfer schemas, a few properties need to be added to apply the SMT, starting with the transforms property. These include, at a minimum, the type of transform in addition to two required properties for the source and destination Schema Registry endpoints. Other configurations can be added, such as the option not to copy the schema for the Kafka record keys, or including HTTP authorization. Refer to the SMT’s README for additional configurations. For simplicity, record keys and HTTPS configurations are excluded from this post. 
# 
# /scripts/2_PUT-update-replicator-with-transform.sh
docker-compose exec kafka-connect bash -c "/scripts/2_PUT-update-replicator-with-transform.sh"

#
# Produce another message with the same schema.

# Once Replicator has been updated with the SMT configurations, it then knows how to transfer schemas. 
# The Produce_Records  script is run again to create records similar to those previously sent
# 
# /scripts/0_Produce_Records_v1.sh kafka-a:9092 topic-a http://schema-registry-a:8081
docker-compose exec kafka-connect bash -c "/scripts/0_Produce_Records_v1.sh kafka-a:9092 topic-a http://schema-registry-a:8081"

# Re-run the consumer to verify the topic can now be read from the beginning:
# 
# kafka-avro-console-consumer \
#  --bootstrap-server kafka-b:9092 \
#  --topic topic-a.replica \
#  --property schema.registry.url=http://schema-registry-b:8081 \
#  --from-beginning \
#  --property print.schema.ids=true
docker-compose exec kafka-connect bash -c "kafka-avro-console-consumer --bootstrap-server kafka-b:9092 --topic topic-a.replica --property schema.registry.url=http://schema-registry-b:8081 --from-beginning --property print.schema.ids=true"


# The destination Schema Registry now contains a subject and version for the replicated topic:
#
# curl http://schema-registry-b:8081/subjects
docker-compose exec kafka-connect bash -c "curl -w'\n' http://schema-registry-b:8081/subjects"

docker-compose exec kafka-connect bash -c "curl -w'\n' http://schema-registry-b:8081/subjects/topic-a.replica-value/versions/"

# As the source topic is modified and producers change schemas in a compatible way enforced by the source Schema Registry, 
# those changes are also replicated to the destination via the SMT. 
# A new producer script can be run to demonstrate that behavior.
#
# /scripts/3_Produce_Records_v2.sh kafka-a:9092 topic-a http://schema-registry-a:8081
docker-compose exec kafka-connect bash -c "/scripts/3_Produce_Records_v2.sh kafka-a:9092 topic-a http://schema-registry-a:8081"

# Upon successful replication, the destination Schema Registry has a new version: 
# 
# curl http://schema-registry-b:8081/subjects/topic-a.replica-value/versions/
docker-compose exec kafka-connect bash -c "curl -w'\n' http://schema-registry-b:8081/subjects/topic-a.replica-value/versions/"

# Consuming again and scrolling through the output reveals that there are now different record objects containing a counter field, and the new schema ID of those records is 2. 
#
# kafka-avro-console-consumer \
#  --bootstrap-server kafka-b:9092 \
#  --topic topic-a.replica \
#  --property schema.registry.url=http://schema-registry-b:8081 \
#  --from-beginning \
#  --property print.schema.ids=true
docker-compose exec kafka-connect bash -c "kafka-avro-console-consumer --bootstrap-server kafka-b:9092 --topic topic-a.replica --property schema.registry.url=http://schema-registry-b:8081 --from-beginning --property print.schema.ids=true"
