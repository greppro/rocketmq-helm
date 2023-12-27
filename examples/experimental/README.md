# 部署案例


此处为实验性案例，不可用于生产。

## 部署

```shell
helm upgrade --install rocketmq \
  --namespace rocketmq-demo \
  --create-namespace \
  -f ha-test.yaml \
  ../../charts/rocketmq
```