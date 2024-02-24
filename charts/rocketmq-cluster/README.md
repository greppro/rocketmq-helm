# RocketMQ Helm Chart

https://github.com/itboon/rocketmq-helm

## 版本兼容性

- Kubernetes 1.18+
- Helm 3.3+
- RocketMQ `>= 4.5`

## 添加 helm 仓库

``` shell
## 添加 helm 仓库
helm repo add rocketmq-repo https://helm-charts.itboon.top/rocketmq
helm repo update rocketmq-repo
```

## 部署案例

``` shell
## 部署一个最小化的 rocketmq 集群
## 这里关闭持久化存储，仅演示部署效果
helm upgrade --install rocketmq \
  --namespace rocketmq-demo \
  --create-namespace \
  --set broker.persistence.enabled="false" \
  rocketmq-repo/rocketmq
```

``` shell
## 部署测试集群, 启用 Dashboard (默认已开启持久化存储)
helm upgrade --install rocketmq \
  --namespace rocketmq-demo \
  --create-namespace \
  --set dashboard.enabled="true" \
  --set dashboard.ingress.enabled="true" \
  --set dashboard.ingress.hosts[0].host="rocketmq-demo.example.com" \
  rocketmq-repo/rocketmq
```

``` shell
## 部署高可用集群, 多 Master 多 Slave
## 3个 master 节点，每个 master 具有1个副节点，共6个 broker 节点
helm upgrade --install rocketmq \
  --namespace rocketmq-demo \
  --create-namespace \
  --set broker.size.master="3" \
  --set broker.size.replica="1" \
  --set broker.master.jvmMemory="-Xms2g -Xmx2g" \
  --set broker.master.resources.requests.memory="4Gi" \
  --set nameserver.replicaCount="3" \
  --set dashboard.enabled="true" \
  --set dashboard.ingress.enabled="true" \
  --set dashboard.ingress.hosts[0].host="rocketmq-ha.example.com" \
  rocketmq-repo/rocketmq

```

> 具体资源配额请根据实际环境调整，参考 [examples](https://github.com/itboon/rocketmq-helm/tree/main/examples)

## 部署详情

### RocketMQ 5.x Proxy

5.x 版本中新增了 Proxy 模块，默认不会部署，用户可以按需启用。

``` yaml
image:
  repository: apache/rocketmq
  tag: 5.1.4

proxy:
  enabled: true
  replicaCount: 1
```

### 镜像仓库

``` yaml
image:
  repository: apache/rocketmq
  tag: 4.9.7
```

### 部署特定版本

``` shell
helm upgrade --install rocketmq \
  --namespace rocketmq-demo \
  --create-namespace \
  --set image.tag="5.1.4" \
  rocketmq-repo/rocketmq
```

### 内存管理

集群每个模块提供堆内存管理，例如 `--set broker.master.jvm.maxHeapSize="1024M"` 将堆内存设置为 `1024M`，默认 `Xms` `Xmx` 相等。堆内存配额应该与 Pod `resources` 相匹配。

> 可使用 `jvm.javaOptsOverride` 对 jvm 参数进行修改，设置了此参数则 `maxHeapSize` 失效。

```yaml
broker:
  master:
    jvm:
      maxHeapSize: 1024M
      # javaOptsOverride: "-Xms1024M -Xmx1024M -XX:+UseG1GC"
    resources:
      requests:
        cpu: 100m
        memory: 2Gi

nameserver:
  jvm:
    maxHeapSize: 1024M
    # javaOptsOverride: "-Xms1024M -Xmx1024M -XX:+UseG1GC"
  resources:
    requests:
      cpu: 100m
      memory: 2Gi
```
