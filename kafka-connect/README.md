Kafka Connect Uber jars into `jars/`  

Kafka Connect JDBC Driver jars into `jdbc-jars/`  

Kafka Connect Plugin packages into `plugins/`  

Running `setup.sh` downloads some plugins that I find useful.

**Docker Compose Setup**

```yaml
volumes:
  - ./kafka-connect/jars:/etc/kafka-connect/uber/
  - ./kafka-connect/plugins/:/etc/kafka-connect/plugins/
  - ./kafka-connect/jdbc-jars:/usr/share/java/kafka-connect-jdbc/lib
```

See Confluent Documentation: https://docs.confluent.io/current/connect/managing.html#using-community-connectors

**Example Directory Layout**  

```
kafka-connect/
├── jars
|   └── kafka-connect-backup-0.4.4.jar
├── jdbc-jars
│   └── mssql-jdbc-6.4.0.jre8.jar
├── plugins
│   └── kafka-connect-transform-archive
│       ├── cef-parser-0.0.1.7.jar
│       ├── connect-utils-0.3.105.jar
│       ├── freemarker-2.3.25-incubating.jar
│       ├── guava-18.0.jar
│       ├── jackson-annotations-2.8.0.jar
│       ├── jackson-core-2.8.5.jar
│       ├── jackson-databind-2.8.5.jar
│       └── kafka-connect-transform-archive-0.1.0.3.jar
└── setup.sh
```
