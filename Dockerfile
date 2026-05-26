FROM alpine:3.21

# webd — 90KB 轻量自建网盘
# 二进制由 GitHub Actions workflow 在构建前下载到构建上下文
COPY webd /usr/local/bin/webd

RUN chmod +x /usr/local/bin/webd \
    && mkdir -p /data \
    && ls -lh /usr/local/bin/webd \
    && test -x /usr/local/bin/webd \
    && echo ">>> webd binary verified OK"

EXPOSE 9212

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ENTRYPOINT ["webd"]
CMD ["-w", "/data", "-u", "rlumSDT:admin:admin123", "-l", "0.0.0.0:9212"]
