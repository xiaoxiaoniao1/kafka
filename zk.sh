#!/bin/bash
server="$1 $2 $3"
ip=`ifconfig | grep inet | egrep -v 'inet6|127'|awk -F' ' '{print $2}'|head -n 1`
zookdir=/data/zk/
zkdir=/data/zk/
datadir=/data/zk/data
datalogdir=/data/zk/log
cfg=/data/zk/conf/zoo.cfg
zk_package=apache-zookeeper-3.5.6-bin.tar.gz
if ! [ -x "$(command -v wget)" ]; then
echo 'Error: wget is not installed.' >&2
yum install wget -y
else
echo "wget is install"
fi
if [ ! -d $zookdir ];then
mkdir -p $zookdir
else
echo "zk already exists"
exit
fi
if [ ! -f /tmp/$zk_package  ];then
wget -P /tmp  https://download1346.mediafire.com/fmv65h6lorxg/iht4pakoejcwtbn/apache-zookeeper-3.5.6-bin.tar.gz
fi

if [ $? -eq 0 ];then
tar -xzf apache-zookeeper-3.5.6-bin.tar.gz -C /data/zk --strip-components 1
else
echo "download is failed"
fi
cd $zkdir && mkdir {data,log}
cat >$cfg<<EOF
tickTime=2000
initLimit=5
syncLimit=2
dataDir=$datadir
dataLogDir=$datalogdir
clientPort=2180
server.1=$ip:8880:7770
server.2=$ip:8880:7770
server.3=$ip:8880:7770
4lw.commands.whitelist=*
EOF
