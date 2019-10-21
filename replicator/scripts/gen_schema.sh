#/bin/sh

if [ $# -lt 3 ]; then
    echo "Usage: $(basename $0) <schema-registry> <subject> <limit>"
    exit 1
fi

REGISTRY=$1
SUBJECT=$2
FIELD_PREFIX=${FIELD_PREFIX:="x"}
FIELD_TYPE=${FIELD_TYPE:-"string"}

i=0
while [ $i -lt $3 ] ; do 
  curl -s -X POST -H "Content-Type: application/vnd.schemaregistry.v1+json" \
    --data '{ "schema": "{ \"type\": \"record\", \"name\": \"Record\", \"namespace\": \"io.confluent.example\", \"fields\": [ { \"name\": \"'${FIELD_PREFIX}${i}'\", \"type\": \"'${FIELD_TYPE}'\" } ]}" }' \
    ${REGISTRY}/subjects/${SUBJECT}/versions > /dev/null

  # Every iteration makes a backwards incompatible schema field name change
  # so set compatibility to NONE after first schema is posted 
  if [ $i = 0 ] ; then
    curl -s -XPUT -H "Content-Type: application/vnd.schemaregistry.v1+json" \
      --data '{ "compatibility": "NONE" }' \
      ${REGISTRY}/config/${SUBJECT} > /dev/null
  fi
  i=$(($i+1))
done

echo "Posted $i schemas to ${REGISTRY}/subjects/${SUBJECT}/versions"