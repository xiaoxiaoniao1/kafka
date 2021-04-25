#!/bin/bash
cat >> /data/kafka/config/producer.properties << EOF
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="adminkafka" password="kafkapasswd!@#";
security.protocol=SASL_PLAINTEXT 
sasl.mechanism=PLAIN
EOF


cat >> /data/kafka/config/consumer.properties << EOF
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="adminkafka" password="kafkapasswd!@#";
security.protocol=SASL_PLAINTEXT 
sasl.mechanism=PLAIN
EOF

#/data/kafka/bin/kafka-console-producer.sh --broker-list `ifconfig | grep inet | egrep -v 'inet6|127|192' |awk -F' ' '{print $2}'|head -n 1`:9092 --topic test --producer.config /data/kafka/config/producer.properties

#/data/kafka/bin/kafka-console-consumer.sh --bootstrap-server `ifconfig | grep inet | egrep -v 'inet6|127|192' |awk -F' ' '{print $2}'|head -n 1`:9092 --topic test --from-beginning --consumer.config /data/kafka/config/consumer.properties
