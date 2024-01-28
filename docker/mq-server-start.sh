#!/bin/bash

java -version
if [ "$?" -ne 0 ]; then
  echo "[ERROR] Missing java runtime"
  exit 500
fi
if [ -z "${ROCKETMQ_HOME}" ]; then
  echo "[ERROR] Missing env ROCKETMQ_HOME"
  exit 500
fi
if [ -z "${ROCKETMQ_PROCESS_ROLE}" ]; then
  echo "[ERROR] Missing env ROCKETMQ_PROCESS_ROLE"
  exit 500
fi

export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export CLASSPATH=".:${ROCKETMQ_HOME}/conf:${ROCKETMQ_HOME}/lib/*:${CLASSPATH}"

JAVA_OPT="${JAVA_OPT} -server"
if [ -n $ROCKETMQ_JAVA_OPTIONS_OVERRIDE ]; then
  JAVA_OPT="${JAVA_OPT} ${ROCKETMQ_JAVA_OPTIONS_OVERRIDE}"
else
  JAVA_OPT="${JAVA_OPT} -XX:+UseG1GC"
  JAVA_OPT="${JAVA_OPT} ${ROCKETMQ_JAVA_OPTIONS_EXT}"
  JAVA_OPT="${JAVA_OPT} ${ROCKETMQ_JAVA_OPTIONS_HEAP}"
fi
JAVA_OPT="${JAVA_OPT} -cp ${CLASSPATH}"

export BROKER_CONF_FILE="/etc/rocketmq/broker.conf"
update_broker_conf() {
  local key=$1
  local value=$2
  sed -i "/^${key} *=/d" ${BROKER_CONF_FILE}
  echo "${key} = ${value}" >> ${BROKER_CONF_FILE}
}
init_broker_conf() {
  rm -f ${BROKER_CONF_FILE}
  if [ -f "/etc/rocketmq/broker-base.conf" ]; then
    cp /etc/rocketmq/broker-base.conf ${BROKER_CONF_FILE}
  fi
  echo "" >> ${BROKER_CONF_FILE}
  echo "# generated config" >> ${BROKER_CONF_FILE}
  if [ -n "$ROCKETMQ_CONF_brokerName" ]; then
    update_broker_conf "brokerName" "$ROCKETMQ_CONF_brokerName"
  else
    local broker_name_seq=${HOSTNAME##*-}
    if echo "$broker_name_seq" | grep -E '^[0-9]{1,5}$'; then
      update_broker_conf "brokerName" "broker-g${broker_name_seq}"
    fi
  fi
  if [ "${ROCKETMQ_CONF_brokerRole}" == "SLAVE" ]; then
    update_broker_conf "brokerRole" "SLAVE"
  elif [ "${ROCKETMQ_CONF_brokerRole}" == "SYNC_MASTER" ]; then
    update_broker_conf "brokerRole" "SYNC_MASTER"
  else
    update_broker_conf "brokerRole" "ASYNC_MASTER"
  fi
  if echo "${ROCKETMQ_CONF_brokerId}" | grep -E '^[0-9]+$'; then
    update_broker_conf "brokerId" "${ROCKETMQ_CONF_brokerId}"
  fi
  echo "[exec] cat ${BROKER_CONF_FILE}"
  cat ${BROKER_CONF_FILE}
}

if [ "$ROCKETMQ_PROCESS_ROLE" == "broker" ]; then
  init_broker_conf
  set -x
  java ${JAVA_OPT} org.apache.rocketmq.broker.BrokerStartup -c ${BROKER_CONF_FILE}
elif [ "$ROCKETMQ_PROCESS_ROLE" == "nameserver" ]; then
  set -x
  java ${JAVA_OPT} org.apache.rocketmq.namesrv.NamesrvStartup
elif [ "$ROCKETMQ_PROCESS_ROLE" == "mqnamesrv" ]; then
  set -x
  java ${JAVA_OPT} org.apache.rocketmq.namesrv.NamesrvStartup
elif [ "$ROCKETMQ_PROCESS_ROLE" == "proxy" ]; then
  set -x
  if [ -f $RMQ_PROXY_CONFIG_PATH ]; then
    java ${JAVA_OPT} org.apache.rocketmq.proxy.ProxyStartup -pc $RMQ_PROXY_CONFIG_PATH
  else
    java ${JAVA_OPT} org.apache.rocketmq.proxy.ProxyStartup
  fi
else
  echo "[ERROR] Missing env ROCKETMQ_PROCESS_ROLE"
  exit 500
fi