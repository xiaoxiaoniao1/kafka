#!/bin/bash
zkdir=/data/zk
kafkadir=/data/kafka
zk_str1=jaasLoginRenew
array_lib=(kafka-clients-2.3.1.jar lz4-java-1.6.0.jar slf4j-api-1.7.26.jar slf4j-log4j12-1.7.26.jar snappy-java-1.1.7.3.jar)
if [ `grep -c $zk_str1 $zkdir/conf/zoo.cfg` -eq  0 ];then
  echo "
authProvider.1=org.apache.zookeeper.server.auth.SASLAuthenticationProvider
requireClientAuthScheme=sasl
jaasLoginRenew=3600000" >> $zkdir/conf/zoo.cfg

else
  echo "zoo.cfg配置已经添加"
fi
cat > $zkdir/conf/zoo_jaas.conf << EOF
Server {
    org.apache.kafka.common.security.plain.PlainLoginModule required
    username="zkadmin"
    password="zkpasswd"
    user_kafka="kafkapwd";
};
EOF

if [ `grep -c "zoo_jaas.conf" $zkdir/bin/zkEnv.sh` -eq 0 ];then
  echo "SERVER_JVMFLAGS=\" -Djava.security.auth.login.config=${zkdir}/conf/zoo_jaas.conf\" " >> $zkdir/bin/zkEnv.sh
else
  echo " zkENV 已经添加过配置"
fi

for i in ${array_lib[@]};do
  cp $kafkadir/libs/$i $zkdir/lib/
  echo $kafkadir/libs/$i $zkdir/lib/
done
cat > $kafkadir/config/kafka_server_jaas.conf << EOF
KafkaServer {
 org.apache.kafka.common.security.plain.PlainLoginModule required
 username="adminkafka"
 password="kafkapasswd!@#"
 user_adminkafka="kafkapasswd!@#" ;
};
Client{
 org.apache.kafka.common.security.plain.PlainLoginModule required
 username="kafka"
 password="kafkapwd";
};
EOF
if [ `grep -c "advertised.listeners=SASL_PLAINTEXT" $kafkadir/config/server.properties` -eq 0 ];then
  sed -i 's/PLAINTEXT/SASL_PLAINTEXT/g' $kafkadir/config/server.properties
else
  echo "$kafkadir/config/server.properties已经添加了头配置SASL_PLAINTEXT "
fi
if [ `grep -c "security" $kafkadir/config/server.properties` -eq 0 ];then
  echo "
# Set protocol
security.inter.broker.protocol=SASL_PLAINTEXT
sasl.mechanism.inter.broker.protocol=PLAIN
sasl.enabled.mechanisms=PLAIN
allow.everyone.if.no.acl.found=true
authorizer.class.name=kafka.security.auth.SimpleAclAuthorizer" >> $kafkadir/config/server.properties
else
  echo  "$kafkadir/config/server.properties经添加了配置"
fi

sed -i '201s#KAFKA_OPTS=""#KAFKA_OPTS="-Djava.security.auth.login.config='$kafkadir'/config/kafka_server_jaas.conf"#' $kafkadir/bin/kafka-run-class.sh
