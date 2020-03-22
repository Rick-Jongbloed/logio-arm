FROM arm32v7/node:13-alpine
LABEL MAINTAINER Rick Jonbloed <r.jongbloed@gmail.com>

ENV LOGIO_SERVER_CONFIG_PATH /root/.log.io/server.json
ENV LOGIO_FILE_INPUT_CONFIG_PATH /root/.log.io/inputs/file.json

# Copy in the code and docs
COPY /volumes/pgadmin4/web /pgadmin4
COPY /volumes/docs-builder/docs/en_US/_build/html/ /pgadmin4/docs
COPY requirements.txt /pgadmin4/requirements.txt

# one RUN step
RUN apk add --no-cache --virtual \
        build-deps \
        build-base && \
    apk add \
        supervisord \
        bash && \
    npm install -g bufferutil@4.0.1 --user 'root' && \
    npm install -g utf-8-validate@5.0.2 --user 'root' && \
    npm install -g log.io --user 'root' && \
    apk del --no-cache build-deps && \
    mkdir /etc/supervisord.d

 ADD supervisor-logio-server.conf /etc/supervisord.d/supervisord.conf
 ADD entrypoint.sh /entrypoint.sh
 
EXPOSE 28778

ENTRYPOINT ["/entrypoint.sh"]