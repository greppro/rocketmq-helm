# builder
FROM alpine as builder

ARG rocketmq_version=5.1.4

ENV dl_url="https://dist.apache.org/repos/dist/release/rocketmq/${rocketmq_version}/rocketmq-all-${rocketmq_version}-bin-release.zip"

RUN set -ex \
  ; mkdir -pv /tmp/app \
  ; wget "$dl_url" -O /tmp/app/rocketmq.zip \
  ; cd /tmp/app && unzip rocketmq.zip \
  ; rm -f /tmp/app/rocketmq.zip \
  ; ls -alh /tmp/app \
  ; mv rocketmq-* rocketmq

# container
FROM eclipse-temurin:17-jre-focal

ENV ROCKETMQ_HOME="/opt/rocketmq"

RUN set -ex \
  ; useradd rocketmq --uid 1000 -m -s /bin/bash -d /home/rocketmq \
  ; usermod -g root rocketmq \
  ; mkdir -pv "$ROCKETMQ_HOME" "/etc/rocketmq" \
  ; chown -R 1000:0 "$ROCKETMQ_HOME" "/etc/rocketmq"

COPY --from=0 --chown=1000:0 /tmp/app/rocketmq "$ROCKETMQ_HOME"

COPY mq-server-start.sh /
COPY entrypoint.sh /
COPY broker-base.conf /etc/rocketmq/

RUN set -ex \
  ; rm -f "$ROCKETMQ_HOME/conf/plain_acl.yml" \
  ; rm -rf "$ROCKETMQ_HOME/conf/acl"

WORKDIR $ROCKETMQ_HOME
EXPOSE 9876 10909 10911 10912

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "start" ]