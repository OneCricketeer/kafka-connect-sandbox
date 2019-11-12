#doitlive prompt: damoekri
#doitlive speed: 100000
#doitlive commentecho: false

# The previous steps show how to transfer schemas between empty Schema Registries. 
# This means the IDs in each Schema Registry are the same. 
# The real power of the transform is that it will generate a new schema in the destination when there is a collision. 
#
# To demonstrate this feature, a new schema with the ID of 3 will be generated first in the destination Schema Registry. 
#doitlive commentecho: true
# /scripts/gen_schema.sh http://schema-registry-b:8081 new-subject 1
docker-compose exec kafka-connect bash -c "/scripts/gen_schema.sh http://schema-registry-b:8081 new-subject 1"

# curl http://schema-registry-b:8081/subjects/new-subject/versions/1
docker-compose exec kafka-connect bash -c "curl -s -w'\n\n' http://schema-registry-b:8081/subjects/new-subject/versions/1 | python -m json.tool"

#doitlive commentecho: false
# The third version of topic-a (with ID 3) in the source Schema Registry is created by producing records with a newer schema: 

#doitlive commentecho: true
# /scripts/4_Produce_Records_v3.sh kafka-a:9092 topic-a http://schema-registry-a:8081
docker-compose exec kafka-connect bash -c "/scripts/4_Produce_Records_v3.sh kafka-a:9092 topic-a http://schema-registry-a:8081"

#doitlive commentecho: false
# When comparing the replicated topic’s subject in each Schema Registry, the included IDs are different for the same version of the schema: 

#doitlive commentecho: true
# curl http://schema-registry-a:8081/subjects/topic-a-value/versions/3
docker-compose exec kafka-connect bash -c "curl -s -w'\n\n'  http://schema-registry-a:8081/subjects/topic-a-value/versions/3 | python -m json.tool"
# curl http://schema-registry-b:8081/subjects/topic-a.replica-value/versions/3
docker-compose exec kafka-connect bash -c "curl -s -w'\n\n' http://schema-registry-b:8081/subjects/topic-a.replica-value/versions/3 | python -m json.tool"

#doitlive commentecho: false
# Consuming again shows that we have a new schema ID, which differs from the source

#doitlive commentecho: true
# kafka-avro-console-consumer \
#  --bootstrap-server kafka-b:9092 \
#  --topic topic-a.replica \
#  --property schema.registry.url=http://schema-registry-b:8081 \
#  --from-beginning \
#  --property print.schema.ids=true
docker-compose exec kafka-connect bash -c "kafka-avro-console-consumer --bootstrap-server kafka-b:9092 --topic topic-a.replica --property schema.registry.url=http://schema-registry-b:8081 --from-beginning --property print.schema.ids=true"
