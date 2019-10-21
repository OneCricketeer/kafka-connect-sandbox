#!/bin/sh 

CONNECT_HOST="${CONNECT_HOST:-http://kafka-connect:8083}"

curl -s -X POST "${CONNECT_HOST}/connectors" -w "\n" -H "Content-Type: application/json" -d '
{
    "name": "replicator-example",
    "config": {
        "connector.class": "io.confluent.connect.replicator.ReplicatorSourceConnector",
        "tasks.max": 1,

        "key.converter": "org.apache.kafka.connect.converters.ByteArrayConverter",
        "value.converter": "org.apache.kafka.connect.converters.ByteArrayConverter",

        "topic.whitelist": "topic-a",
        "topic.rename.format": "${topic}.replica",

        "src.kafka.bootstrap.servers": "kafka-a:9092",
        "dest.kafka.bootstrap.servers": "kafka-b:9092",

        "confluent.topic.replication.factor": 1
    }
  }
' | python -m json.tool # for formatting