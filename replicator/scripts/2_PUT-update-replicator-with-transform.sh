#!/bin/sh 

CONNECT_HOST="${CONNECT_HOST:-http://kafka-connect:8083}"

curl -X PUT "${CONNECT_HOST}/connectors/replicator-example/config" -s -w "\n" -H "Content-Type: application/json" -d '
{    
    "connector.class": "io.confluent.connect.replicator.ReplicatorSourceConnector",
    "tasks.max": 1,

    "key.converter": "org.apache.kafka.connect.converters.ByteArrayConverter",
    "value.converter": "org.apache.kafka.connect.converters.ByteArrayConverter",

    "topic.whitelist": "topic-a",
    "topic.rename.format": "${topic}.replica",

    "src.kafka.bootstrap.servers": "kafka-a:9092",
    "dest.kafka.bootstrap.servers": "kafka-b:9092",

    "confluent.topic.replication.factor": 1,

    "transforms": "AvroSchemaTransfer",
    "transforms.AvroSchemaTransfer.type": "cricket.jmoore.kafka.connect.transforms.SchemaRegistryTransfer",
    "transforms.AvroSchemaTransfer.transfer.message.keys": "false",
    "transforms.AvroSchemaTransfer.src.schema.registry.url": "http://schema-registry-a:8081",
    "transforms.AvroSchemaTransfer.dest.schema.registry.url": "http://schema-registry-b:8081"
}
' | python -m json.tool # for formatting

