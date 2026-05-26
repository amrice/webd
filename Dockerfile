FROM alpine:3.21

COPY webd-bin /usr/local/bin/webd

RUN chmod +x /usr/local/bin/webd \
    && mkdir -p /data

EXPOSE 9212
ENTRYPOINT ["webd"]
CMD ["-w", "/data", "-u", "rlumSDT:admin:admin123", "-l", "0.0.0.0:9212"]
