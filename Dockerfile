FROM alpine:3.21

COPY webd-bin /usr/local/bin/webd
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /usr/local/bin/webd /entrypoint.sh \
    && mkdir -p /data/share

EXPOSE 9212
ENTRYPOINT ["/entrypoint.sh"]
