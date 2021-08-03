FROM 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_base:latest

ARG ARCH="amd64"
ARG OS="linux"
ARG VER="2.28.1"
ARG PKG="prometheus"
ARG SRC="${PKG}-${VER}.${OS}-${ARCH}"
ARG UID="nobody"
ARG GID="nobody"

LABEL ORG="Armedia LLC"
LABEL MAINTAINER="Armedia LLC"
LABEL APP="Prometheus"
LABEL VERSION="${VER}"
LABEL IMAGE_SOURCE="https://github.com/ArkCase/ark_prometheus"

# Modify to fetch from S3 ...
RUN curl \
        -L "https://github.com/prometheus/${PKG}/releases/download/v${VER}/${SRC}.tar.gz" \
        -o - | tar -xzvf -
RUN mkdir -pv \
        "/app/data" \
        "/app/conf" \
        "/usr/share/prometheus"
RUN mv -vif \
        "${SRC}/LICENSE" \
        "/LICENSE"
RUN mv -vif \
        "${SRC}/NOTICE" \
        "/NOTICE"
RUN mv -vif \
        "${SRC}/prometheus" \
        "/bin/prometheus"
RUN mv -vif \
        "${SRC}/promtool" \
        "/bin/promtool"
RUN mv -vif \
        "${SRC}/prometheus.yml" \
        "/app/conf/prometheus.yml"
RUN mv -vif \
        "${SRC}/console_libraries/" \
        "/usr/share/prometheus/"
RUN mv -vif \
        "${SRC}/consoles/" \
        "/usr/share/prometheus/"
RUN ln -sv \
        "/usr/share/prometheus/console_libraries" \
        "/app/conf"
RUN ln -sv \
        "/usr/share/prometheus/consoles" \
        "/app/conf"
RUN ln -sv \
        "/app/conf" \
        "/etc/prometheus"
RUN chown -R "${UID}:${GID}" \
        "/app/data" \
        "/app/conf"
RUN chmod -R ug+rwX,o-rwx \
        "/app/data" \
        "/app/conf"
RUN rm -rvf \
        "${SRC}"

#COPY npm_licenses.tar.bz2    /npm_licenses.tar.bz2

USER        ${UID}
EXPOSE      9090
VOLUME      [ "/app/data", "/app/conf" ]
WORKDIR     /app/data
ENTRYPOINT  [ "/bin/prometheus" ]
CMD         [ "--config.file=/app/conf/prometheus.yml", \
              "--storage.tsdb.path=/app/data", \
              "--web.console.libraries=/usr/share/prometheus/console_libraries", \
              "--web.console.templates=/usr/share/prometheus/consoles" ]
