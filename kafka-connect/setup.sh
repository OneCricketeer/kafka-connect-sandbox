#!/usr/bin/env bash

download_mvn_central_jdbc() {
  mvncentral='http://central.maven.org/maven2'
  if [ $# -ne 1 ]; then
    echo "Downloads a file from Maven Central"
    echo "Usage: download_mvn_central_jdbc <url>"
    exit 1
  fi

  package=$1
  wget -nc -P ./jdbc-jars "${mvncentral}/${package}"
}

download_kafkaconnect_plugin() {
  if [ $# -lt 2 ]; then
    echo "Downloads a .tar.gz Kafka Connect plugin, such as those from Confluent Hub"
    echo "Usage: download_kafkaconnect_plugin <url> <plugin_name>"
    exit 1
  fi
  url=$1
  plugin_name=$2

  filename=$(basename $1)
  # plugin_name=$(basename -s '.tar.gz' $filename | cut -d'-' -f1-4)  # only works if 4 parts to the name

  wget -nc "$url"
  # extracts only the folder with the JAR files
  tar -xvzf "${filename}" -C ./plugins --strip-components=3 "usr/share/kafka-connect/${plugin_name}"
}

download_kafkaconnect_jar() {
  if [ $# -ne 1 ]; then
    echo "Downloads a Kafka Connect Uber JAR plugin"
    echo "Usage: download_kafkaconnect_jar <url>"
    exit 1
  fi

  url=$1
  wget -nc -P ./jars "${url}"
}

transform_archive_version=0.1.0.3
download_kafkaconnect_plugin \
  "https://github.com/jcustenborder/kafka-connect-transform-archive/releases/download/${transform_archive_version}/kafka-connect-transform-archive-${transform_archive_version}.tar.gz" \
  kafka-connect-transform-archive

mssql_jdbc_version=6.4.0.jre8
download_mvn_jdbc_jar "com/microsoft/sqlserver/mssql-jdbc/${mssql_jdbc_version}/mssql-jdbc-${mssql_jdbc_version}.jar"
