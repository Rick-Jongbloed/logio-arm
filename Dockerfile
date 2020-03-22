FROM arm32v7/node:13-alpine
LABEL MAINTAINER Rick Jonbloed <r.jongbloed@gmail.com>

ENV LOGIO_SERVER_CONFIG_PATH /root/.log.io/server.json

# one RUN step
RUN apk add --no-cache --virtual \
        build-deps \
        build-base && \
    apk add \
        supervisor \
        bash && \
    npm install -g bufferutil@4.0.1 --user 'root' && \
    npm install -g utf-8-validate@5.0.2 --user 'root' && \
    npm install -g log.io --user 'root' && \
    apk del --no-cache build-deps && \
    mkdir /etc/supervisord.d && \
    chmod +x /drone/src/entrypoint.sh
    

USER root
ADD server.json /root/.log.io/server.json
ADD supervisor.conf /etc/supervisor/conf.d/supervisor.conf
ADD entrypoint.sh /entrypoint.sh

EXPOSE 6688 6689

ENTRYPOINT ["/entrypoint.sh"]