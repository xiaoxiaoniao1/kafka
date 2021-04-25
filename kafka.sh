#/bin/bash
echo "pleas input zookip "
if [ $# -eq 0 ];then
echo "args is not null"
exit
fi
kafkadir=/data/kafka
kafka_logs=/data/kafka/logs
kafka_ip=`ifconfig | grep inet | egrep -v 'inet6|127|192' |awk -F' ' '{print $2}'|head -n 1`
kafka_cfg=/data/kafka/config/server.properties
kafak_package=kafka_2.12-2.3.1.tgz
if ! [ -x "$(command -v wget )" ]; then
yum install wget -y
fi
if [ ! -d $kafkadir ];then
mkdir -p $kafkadir
else
echo "kafka already exists"
exit
fi
if [ ! -f /tmp/$kafak_package ];then
  echo "no download kafka"
  wget -P /tmp/ https://download1474.mediafire.com/af5s6mim24gg/4zbpvmrhj3dzxjk/kafka_2.12-2.3.1.tgz
else
  echo "aready down kafka!"
  echo $kafak_package
fi

if [ $? -eq 0 ];then
echo $?
tar xf /tmp/kafka_2.12-2.3.1.tgz -C /data/kafka --strip-components 1
else
echo "download is failed"
fi
echo $kafka_ip
cat > $kafka_cfg <<EOF
broker.id=2
listeners=PLAINTEXT://$kafka_ip:9092
advertised.listeners=PLAINTEXT://$kafka_ip:9092
zookeeper.connect=$1:2181,$2:2181,$3:2181
log.dirs=/data/kafka/logs
num.network.threads=24 
num.io.threads=60 
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
num.partitions=3 
num.recovery.threads.per.data.dir=8
offsets.topic.replication.factor=3
transaction.state.log.replication.factor=3
transaction.state.log.min.isr=3
log.cleanup.policy=delete
log.retention.bytes=1073741824
log.retention.hours=48
log.segment.bytes=107374182
log.retention.check.interval.ms=300000 
zookeeper.connection.timeout.ms=6000 
group.initial.rebalance.delay.ms=3
auto.create.topics.enable=false 
auto.leader.rebalance.enable=true   
background.threads=15 
delete.topic.enable=true 
leader.imbalance.check.interval.seconds=300 
leader.imbalance.per.broker.percentage=10 
default.replication.factor=2 
controlled.shutdown.enable=true
EOF
