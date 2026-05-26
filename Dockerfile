FROM alpine:3.21

# webd — 90KB 轻量自建网盘
# 支持通过 ARG 指定版本号，默认 20240223
ARG WEBD_VERSION=20240223

# 直接从 GitHub raw CDN 下载 webd 二进制（musl libc 版本）
ADD https://raw.githubusercontent.com/webd90kb/webd/master/docs/webd/webd_dl/${WEBD_VERSION}/webd-${WEBD_VERSION}-x86_64-linux-musl.tar.gz /tmp/webd.tar.gz

RUN tar -xzf /tmp/webd.tar.gz -C /tmp \
    && cp /tmp/webd/webd /usr/local/bin/webd \
    && chmod +x /usr/local/bin/webd \
    && rm -rf /tmp/webd /tmp/webd.tar.gz \
    && mkdir -p /data \
    && ls -lh /usr/local/bin/webd

EXPOSE 9212
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENTRYPOINT ["webd"]
CMD ["-w", "/data", "-u", "rlumSDT:admin:admin123", "-l", "0.0.0.0:9212"]
