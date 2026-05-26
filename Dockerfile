FROM alpine:3.21

COPY webd-binary /usr/local/bin/webd

RUN chmod +x /usr/local/bin/webd \
    && mkdir -p /data \
    && ls -lh /usr/local/bin/webd

EXPOSE 9212
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENTRYPOINT ["webd"]
CMD ["-w", "/data", "-u", "rlumSDT:admin:admin123", "-l", "0.0.0.0:9212"]
