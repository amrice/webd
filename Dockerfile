FROM alpine:3.21

COPY webd-bin /usr/local/bin/webd
COPY entrypoint.sh /entrypoint.sh
COPY .player.htm /opt/player/.player.htm

RUN chmod +x /usr/local/bin/webd /entrypoint.sh \
    && mkdir -p /data/share /opt/player

EXPOSE 9212
ENTRYPOINT ["/entrypoint.sh"]
