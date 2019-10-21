#!/bin/sh

if [ $# -lt 3 ]; then
    echo "Usage: $(basename $0) <broker-list> <topic> <schema-registry>"
    exit 1
fi

BROKER_LIST=$1
TOPIC=$2
SCHEMA_REGISTRY=$3

for i in $(seq 20); do
    TIME=$(date +%s%3N)
    echo "{\"time\":$TIME, \"desc\":\"record at $TIME\", \"counter\":$i}" >> /tmp/data.txt
done

kafka-avro-console-producer \
    --broker-list "${BROKER_LIST}"  \
    --topic "${TOPIC}"  \
    --property schema.registry.url="${SCHEMA_REGISTRY}"  \
    --property value.schema="$(cat /scripts/record_v2.avsc)" < /tmp/data.txt

if [ $? -eq 0 ]; then 
    _cnt=$(wc -l /tmp/data.txt | awk '{print $1}')
    echo "Produced $_cnt records." && rm -f /tmp/data.txt
fi