# 部署案例


此处为实验性案例，不可用于生产。

## 部署

```shell
# NodePort
helm upgrade --install rocketmq \
  --namespace rocketmq-demo \
  --create-namespace \
  --set broker.persistence.enabled="false" \
  --set dashboard.service.type="NodePort" \
  --set dashboard.service.nodePort="31007" \
  ../../charts/rocketmq

# cluster test
helm upgrade --install rocketmq \
  --namespace rocketmq-demo \
  --create-namespace \
  -f minikube-common.yaml \
  ../../charts/rocketmq-cluster

```