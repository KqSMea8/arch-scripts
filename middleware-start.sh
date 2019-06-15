#!/usr/bin/env bash

# Location:
ZK_HOME=/opt/apache/zookeeper/zookeeper-3.4.13
ZKDEV_HOME=/opt/others/ZooInspector
EDAS_CONFIG_CENTER_HOME=/opt/alibaba/edas-config-center
REDIS_CLUSTER_HOME=/opt/redis/cluster
REDIS_HA_HOME=/opt/redis/HA
REDIS_SENTINEL_HOME=/opt/redis/sentinel
KAFKA_HOME=/opt/apache/kafka/kafka_2.11-2.0.0
ROCKETMQ_HOME=/opt/apache/rocketmq/rocketmq-all-4.3.1-bin-release
ROCKETMQ_CONSOLE_HOME=/opt/apache/rocketmq/rocketmq-console-ng
ACTIVEMQ_HOME=/opt/apache/activemq/apache-activemq-5.15.3
JREBEL_BRAINS_LICENSE_SERVER_HOME=/opt/others/JrebelBrainsLicenseServer

# Zookeeper
zk_start() {
	echo 'Zookeeper start... '
	cd $ZK_HOME
	cd bin
	echo "" > /opt/cache/middleware-logs/zk.log
	nohup sh zkServer.sh start > /opt/cache/middleware-logs/zk.log &
}
zk_stop() {
	echo 'Zookeeper stop... '
	cd $ZK_HOME
	cd bin
	echo "" > /opt/cache/middleware-logs/zk.log
	nohup sh zkServer.sh stop >  /opt/cache/middleware-logs/zk.log &
}
zk_env() {
   mkdir -p  /opt/cache/middleware-logs
	if [ "start" == "${ACTION_TYPE}" ] ;then
		zk_start
   elif [ "stop" == "${ACTION_TYPE}" ] ;then
	 	zk_stop
   else
		echo 'Zookeeper restart... '
		cd $ZK_HOME
		nohup sh zkServer.sh restart > /opt/cache/middleware-logs/zk.log &
	fi
}

# ZooInspector
zkdev_env() {
	echo 'ZooInspector start... '
	 cd $ZKDEV_HOME
	 nohup sh start.sh &
	#  check 
	sleep 2s
	 PID=`ps -ef | grep 'zookeeper-dev-ZooInspector.jar'|grep -v grep |head -n 1 | awk 
'{print $2}'`
	if [ -z $PID ]; then
	        echo 'ZooInspector start failed  !!! '
	 else
	 	echo 'ZooInspector has been start successfully.'
	fi
}

# EDAS
edas_env() {
   mkdir -p  /opt/cache/middleware-logs
   cd $EDAS_CONFIG_CENTER_HOME
	if [ "start" == "${ACTION_TYPE}" ] ;then
		echo 'EDAS start... '
		sh startup.sh 
   elif [ "stop" == "${ACTION_TYPE}" ] ;then
   		echo 'EDAS stop... '
	 	sh shutdown.sh 
   else	
   		echo 'EDAS stop... '
		sh shutdown.sh 
		sleep 3s
		echo 'EDAS start... '
		sh startup.sh 
	fi
}

# Docker
docker_env() {
   sudo systemctl ${ACTION_TYPE} docker
}

# Nginx
nginx_env() {
   if [ "start" == "${ACTION_TYPE}" ] ;then
   		echo 'Nginx start... '
		sudo nginx
   elif [ "stop" == "${ACTION_TYPE}" ] ;then
   		echo 'Nginx stop... '
	 	sudo nginx -s stop
   else
		echo 'Nginx realod... '
		sudo nginx -s realod
   fi
}

# MySQL
mysql_env() {
	 sudo systemctl ${ACTION_TYPE} mysqld.service
}

# Redis Cluster
redis_c_start() {
	echo 'Redis Cluster start... '
	 cd $REDIS_CLUSTER_HOME
	 sh start.sh
}
redis_c_stop() {
	echo 'Redis Cluster stop... '
	cd $REDIS_CLUSTER_HOME
	sh stop.sh
} 
redis_c_env() {
   mkdir -p  /opt/cache/middleware-logs/redis-cluster
	if [ "start" == "${ACTION_TYPE}" ] ;then
		redis_c_start
   elif [ "stop" == "${ACTION_TYPE}" ] ;then
	 	redis_c_stop
   else
		redis_c_stop
		sleep 3s
		redis_c_start
	fi
}

# Redis HA
redis_ha_start() {
	echo 'Redis HA start... '
	 cd $REDIS_HA_HOME
	 sh start.sh 
}
redis_ha_stop() {
	echo 'Redis HA stop... '
	cd $REDIS_HA_HOME
	sh stop.sh
} 
redis_ha_env() {
  mkdir -p  /opt/cache/middleware-logs/redis-ha
	if [ "start" == "${ACTION_TYPE}" ] ;then
		redis_ha_start
   elif [ "stop" == "${ACTION_TYPE}" ] ;then
	 	redis_ha_stop
   else
		redis_ha_stop
		sleep 3s
		redis_ha_start
	fi
}


# Redis HA + Sentinel
redis_has_start() {
	echo 'Redis HA start... '
	 cd $REDIS_HA_HOME
	 sh start.sh 
	 sleep 3s
	 echo 'Sentinel start... '
	 cd $REDIS_SENTINEL_HOME
	 sh start.sh 
}
redis_has_stop() {
	echo 'Redis HA stop... '
	cd $REDIS_HA_HOME
	sh stop.sh 
	 sleep 3s
	 echo 'Sentinel stop... '
	 cd $REDIS_SENTINEL_HOME
	 sh stop.sh 
} 
redis_has_env() {
   mkdir -p  /opt/cache/middleware-logs/redis-redis-sentinel
	if [ "start" == "${ACTION_TYPE}" ] ;then
		redis_has_start
   elif [ "stop" == "${ACTION_TYPE}" ] ;then
	 	redis_has_stop
   else
		redis_has_stop
		sleep 3s
		redis_has_start
	fi
}

# Kafka
kafka_start(){
	zk_start
	echo 'Kafka start... '
	cd $KAFKA_HOME
	nohup bin/kafka-server-start.sh config/high-p/server-0.properties > /opt/cache/middleware-logs/kafka/server-0.log 2>&1 &
	nohup bin/kafka-server-start.sh config/high-p/server-1.properties > /opt/cache/middleware-logs/kafka/server-1.log 2>&1 &
}
kafka_stop(){
	echo 'Kafka stop... '
	cd $KAFKA_HOME
	nohup bin/kafka-server-stop.sh > /opt/cache/middleware-logs/kafka/stop.log 2>&1 &
}
kafka_env(){
    mkdir -p  /opt/cache/middleware-logs/kafka
	if [ "start" == "${ACTION_TYPE}" ] ;then
		kafka_start
	elif [ "stop" == "${ACTION_TYPE}" ] ;then
		kafka_stop
	else
		kafka_stop
		sleep 3s
		kafka_start
	fi
}

# RocketMQ
rkmq_start() {
	 cd $ROCKETMQ_HOME
	 if [ ! -e "${ROCKETMQ_HOME}/logs" ];then mkdir "${ROCKETMQ_HOME}/logs";fi
	 if [ "2m-2s" == "${BROKER_MODE}" ] ; then
		echo 'RocketMQ (2m-2s) start... '
		sh start-2m2s.sh 
	 else 
		echo 'RocketMQ (1m-1s) start... '
		sh start.sh 
	 fi
	 # check 
	sleep 2s
	 BROKERPID=`ps aux | grep java | awk '/broker/'|grep -v grep |head -n 1 | awk 
'{print $2}'`
	if [ -z $BROKERPID ]; then
	        echo 'Rocketmq Broker start failed  !!! '
	 else
	 	echo 'Rocketmq Broker has been start successfully.'
	fi
	 rkmq_web_start
}
rkmq_stop() {
	echo 'RocketMQ stop... '
	cd $ROCKETMQ_HOME
	sh stop.sh
} 
rkmq_env() {
   mkdir -p  /opt/cache/middleware-logs/rocketmq
	BROKER_MODE='1m-1s'
	if [ "start" == "${ACTION_TYPE}" ] ;then
		rkmq_start
   elif [ "stop" == "${ACTION_TYPE}" ] ;then
	 	rkmq_stop
   else
		rkmq_stop
		sleep 3s
		rkmq_start
	fi
}
rkmq2_env() {
    mkdir -p  /opt/cache/middleware-logs/rocketmq
	BROKER_MODE='2m-2s'
	if [ "start" == "${ACTION_TYPE}" ] ;then
		rkmq_start
   elif [ "stop" == "${ACTION_TYPE}" ] ;then
	 	rkmq_stop
   else
		rkmq_stop
		sleep 3s
		rkmq_start
	fi
}
# RocketMQ Console
rkmq_web_start() {
   echo 'RocketMQ-Console start... '
   cd $ROCKETMQ_CONSOLE_HOME
   echo "" > app.log
   nohup java -jar rocketmq-console-ng-1.0.0.jar > /opt/cache/middleware-logs/rocketmq-console.log 2>&1 &
   # check 
	PID=`ps -ef | grep 'java -jar rocketmq-console-ng-1.0.0.jar'|grep -v grep |head -n 1 
| awk '{print $2}'`
	if [ -z $PID ];
	then 
	        echo 'Rocketmq-Console start failed  !!! '
	else
	        echo 'Rocketmq-Console has been start successfully.'
	fi
}
rkmq_web_stop() {
	echo 'RocketMQ-Console stop... '
	PID=`ps -ef | grep 'java -jar rocketmq-console-ng-1.0.0.jar'|grep -v grep |head -n 1 
| awk '{print $2}'`
	if [ -z $PID ];
	then 
	        echo 'Cannot find Rocketmq-Console process.'
	else
	        kill -9 $PID
	        echo 'Rocketmq-Console has been shutdown successfully.'
	fi
}
rkmq_web_env() {
	if [ "start" == "${ACTION_TYPE}" ] ;then
		rkmq_web_start
   elif [ "stop" == "${ACTION_TYPE}" ] ;then
	 	rkmq_web_stop
   else
		rkmq_web_stop
		sleep 3s
		rkmq_web_start
	fi
}

# ActiveMQ
amq_env() {
   mkdir -p  /opt/cache/middleware-logs/activemq
	cd $ACTIVEMQ_HOME
   if [ "start" == "${ACTION_TYPE}" ] ;then
   		echo 'ActiveMQ start... '
		nohup sh bin/activemq start > /opt/cache/middleware-logs/activemq/start.log  &
   elif [ "stop" == "${ACTION_TYPE}" ] ;then
   		echo 'ActiveMQ stop... '
	 	nohup sh bin/activemq stop > /opt/cache/middleware-logs/activemq/stop.log  &
   else
   		echo 'ActiveMQ stop... '
		nohup sh bin/activemq stop  > /opt/cache/middleware-logs/activemq/stop.log &
		sleep 3s
		echo 'ActiveMQ start... '
		nohup sh bin/activemq start > /opt/cache/middleware-logs/activemq/start.log &
	fi
}

# RocketMQ Console
jrebel_web_start() {
   echo 'Jrebel Brains License Server start... '
   cd $JREBEL_BRAINS_LICENSE_SERVER_HOME
   echo "" > app.log
   nohup java -jar JrebelBrainsLicenseServerforJava-1.0-SNAPSHOT-jar-with-dependencies.jar > /opt/cache/middleware-logs/jrebel-server.log 2>&1 &
   # check 
	PID=`ps -ef | grep 'java -jar 
JrebelBrainsLicenseServerforJava-1.0-SNAPSHOT-jar-with-dependencies.jar'|grep -v grep |head 
-n 1 | awk '{print $2}'`
	if [ -z $PID ];
	then 
	        echo 'Jrebel Brains License Server start failed  !!! '
	else
	        echo 'Jrebel Brains License Server has been start successfully.'
			sleep 3s	
	        cat app.log
	fi
}
jrebel_web_stop() {
	echo 'Jrebel Brains License Server stop... '
	PID=`ps -ef | grep 'java -jar 
JrebelBrainsLicenseServerforJava-1.0-SNAPSHOT-jar-with-dependencies.jar'|grep -v grep |head 
-n 1 | awk '{print $2}'`
	if [ -z $PID ];
	then 
	        echo 'Cannot find Jrebel Brains License Server process.'
	else
	        kill -9 $PID
	        echo 'Jrebel Brains License Server has been shutdown successfully.'
	fi
}
jrebel_web_env() {
	if [ "start" == "${ACTION_TYPE}" ] ;then
		jrebel_web_start
   elif [ "stop" == "${ACTION_TYPE}" ] ;then
	 	jrebel_web_stop
   else
		jrebel_web_stop
		sleep 3s
		jrebel_web_start
	fi
}

print(){
    echo '----------------------------Middleware Quick Start----------------------------' 
    echo "Middleware Environment : $COMP_NAME"
    echo "Middleware Action Type : $ACTION_TYPE"
    echo '----------------------------Middleware Quick Start----------------------------'
}

go(){
	 echo 'Please Enter your option: [Environment]  [Action Type]  >'
	 COMP_NAME='UnKnown'
	 ACTION_TYPE='start'
	 FLAG='c'
    read COMP_TYPE ACTION_TYPE
         # 调用对应环境函数
    if [ "zk" == "${COMP_TYPE}" ] ;then
		 COMP_NAME='Apache Zookeeper'
    	 print
		 zk_env
    elif [ "zkdev" == "${COMP_TYPE}" ] ;then
		 COMP_NAME='ZooInspector'
    	 print
		 zkdev_env
    elif [ "edas" == "${COMP_TYPE}" ] ;then
	    COMP_NAME='Alibaba EDAS'
    	 print
		 edas_env
    elif [ "docker" == "${COMP_TYPE}" ] ;then
		 COMP_NAME='Docker'       
    	 print			
    	 docker_env
    elif [ "nginx" == "${COMP_TYPE}" ] ;then
		 COMP_NAME='Nginx'
    	 print
    	 nginx_env
    elif [ "mysql" == "${COMP_TYPE}" ] ;then
		 COMP_NAME='MySQL'
    	 mysql_env
    elif [ "redis" == "${COMP_TYPE}" ] ;then
		 COMP_NAME='Redis Cluster'
    	 print
    	 redis_c_env
    elif [ "redis_ha" == "${COMP_TYPE}" ] ;then
		 COMP_NAME='Redis HA (3m3s)'
    	 print
    	 redis_ha_env
    elif [ "redis_has" == "${COMP_TYPE}" ] ;then
		 COMP_NAME='Redis HA (3m3s)+ Sentinel(3)'
    	 print
    	 redis_has_env
    elif [ "kafka" == "${COMP_TYPE}" ] ;then
		 COMP_NAME='Apache Kafka'
    	 print
    	 kafka_env
    elif [ "rkmq" == "${COMP_TYPE}" ] ;then
		 COMP_NAME='Apache RocketMQ (1m1s)'
    	 print
    	 rkmq_env
	 elif [ "rkmq2" == "${COMP_TYPE}" ] ;then
		 COMP_NAME='Apache RocketMQ (2m2s)'
    	 print
    	 rkmq2_env
    elif [ "rkmq_web" == "${COMP_TYPE}" ] ;then
		 COMP_NAME='Apache RocketMQ Console'
    	 print
    	 rkmq_web_env
    elif [ "amq" == "${COMP_TYPE}" ] ;then
		 COMP_NAME='Apache ActiveMQ'
    	 print
    	 amq_env
    elif [ "jrebel" == "${COMP_TYPE}" ] ;then
		 COMP_NAME='Jrebel Brains License Server'
    	 print
    	 jrebel_web_env	 
    else
		echo 'Not middleware environment matched.'
    fi
	echo 'Continue(c) or Quit(q) ? '
	read FLAG
	if [ "c" == "${FLAG}" ] ;then
		go
	fi
}

# 入口环境
main() {
    echo '----------------------------Middleware Quick Start----------------------------'
    echo 'Support Environment (arg0):
    			Apache Zookeeper             ==>   zk
    			ZooInspector                 ==>   zkdev
    			Alibaba EDAS                 ==>   edas
    			Docker                       ==>   docker
    			Nginx                        ==>   nginx
    			MySQL                        ==>   mysql
    			Redis Cluster                ==>   redis
    			Redis HA (3m3s)              ==>   redis_ha
    			Redis HA (3m3s)+ Sentinel(3) ==>   redis_has
    			Apache Kafka                 ==>   kafka
    			Apache RocketMQ (1m1s)       ==>   rkmq
    			Apache RocketMQ (2m2s)       ==>   rkmq2
    			Apache RocketMQ Console      ==>   rkmq_web
    			Apache ActiveMQ              ==>   amq
    			Jrebel Brains License Server ==>   jrebel
'
    echo 'Support Action Type (arg1): 
    			Start Middleware             ==>   start
    			Stop Middleware              ==>   stop
    			Restart Middleware           ==>   restart
'
    go
}
# 开始执行
main


