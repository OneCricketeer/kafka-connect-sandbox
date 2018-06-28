Kafka Connect Uber jars into `jars/`  

Kafka Connect Plugin packages into `plugins/`  

**Docker Compose Setup**

```yaml
volumes:
  - ./kafka-connect/jars:/etc/kafka-connect/jars
  - ./kafka-connect/plugins/:/etc/kafka-connect/plugins/
```

See Confluent Documentation: https://docs.confluent.io/current/connect/managing.html#using-community-connectors

**Example**  

```
kafka-connect/
├── README.md
├── jars
│   └── kafka-connect-backup-0.4.4.jar
└── plugins
    └── kafka-connect-transform-archive
        ├── cef-parser-0.0.1.7.jar
        ├── connect-utils-0.3.115.jar
        ├── freemarker-2.3.25-incubating.jar
        ├── guava-18.0.jar
        ├── jackson-annotations-2.8.0.jar
        ├── jackson-core-2.8.5.jar
        ├── jackson-databind-2.8.5.jar
        └── kafka-connect-transform-archive-0.2.0-SNAPSHOT.jar
```
