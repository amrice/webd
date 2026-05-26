FROM alpine:3.21

# webd — 90KB 轻量自建网盘
# 二进制由 GitHub Actions workflow 在构建前下载到构建上下文
COPY webd /usr/local/bin/webd

RUN chmod +x /usr/local/bin/webd \
    && mkdir -p /data

EXPOSE 9212

# webd 启动后自动加载 /etc/webd.conf（如挂载了配置文件）
# 以下 CMD 为默认命令行参数，可被 docker-compose 覆盖
ENTRYPOINT ["webd"]
CMD ["-w", "/data", "-u", "rlumSDT:admin:admin123", "-l", "0.0.0.0:9212"]
