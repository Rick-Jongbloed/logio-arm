FROM arm32v7/node:13-alpine

#expose:
#LOGIO_SERVER_CONFIG_PATH
#LOGIO_FILE_INPUT_CONFIG_PATH


COPY  /volumes/usr/local/pgsql /usr/local/

WORKDIR /pgadmin4
ENV PYTHONPATH=/pgadmin4

# Copy in the code and docs
COPY /volumes/pgadmin4/web /pgadmin4
COPY /volumes/docs-builder/docs/en_US/_build/html/ /pgadmin4/docs
COPY requirements.txt /pgadmin4/requirements.txt

# Install build-dependencies, build & install C extensions and purge deps in
# one RUN step
RUN apk add --no-cache --virtual \
        build-deps \
        build-base \
        postgresql-dev \
        libffi-dev \
        linux-headers && \
    apk add \
        postfix \
        postgresql-client \
        postgresql-libs \
        shadow \
        libcap && \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir gunicorn==19.9.0 && \
    apk del --no-cache build-deps

# We need the v12 usrlibpq, which is only in the 'edge' build of Alpine at present
COPY /volumes/usr/local/pgsql/pgsql-9.12/libpq.so.5.12 /usr/lib/
RUN ln -sf /usr/lib/libpq.so.5.12 /usr/lib/libpq.so.5 
#&& ls -la && rm /usr/local/pgsql/pgsql-9.12/libpq.so.5.12

# Copy the runner script
COPY pkg/docker/run_pgadmin.py /pgadmin4
COPY pkg/docker/entrypoint.sh /entrypoint.sh

# Precompile and optimize python code to save time and space on startup
RUN python -O -m compileall -x node_modules /pgadmin4

RUN groupadd -g 5050 pgadmin && \
    useradd -r -u 5050 -g pgadmin pgadmin && \
    mkdir -p /var/lib/pgadmin && \
    chown pgadmin:pgadmin /var/lib/pgadmin && \
    mkdir -p /var/log/pgadmin && \
    chown pgadmin:pgadmin /var/log/pgadmin && \
    touch /pgadmin4/config_distro.py && \
    chown pgadmin:pgadmin /pgadmin4/config_distro.py && \
    setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/python3.7
USER pgadmin

# Finish up
VOLUME /var/lib/pgadmin
EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]