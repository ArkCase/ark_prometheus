ARG ARCH="amd64"
ARG OS="linux"
#FROM quay.io/prometheus/busybox-${OS}-${ARCH}:latest
FROM centos:7
LABEL maintainer="Armedia, LLC"

ARG ARCH="amd64"
ARG OS="linux"
ARG VER="2.28.1"
ARG PKG="prometheus"
ARG SRC="${PKG}-${VER}.${OS}-${ARCH}"

RUN curl -L "https://github.com/prometheus/${PKG}/releases/download/v${VER}/${SRC}.tar.gz" -o package.tar.gz
RUN tar -xzvf "package.tar.gz"
RUN mv -vif "${SRC}/LICENSE"                     "/LICENSE"
RUN mv -vif "${SRC}/NOTICE"                      "/NOTICE"

RUN mv -vif "${SRC}/prometheus"                  "/bin/prometheus"
RUN mv -vif "${SRC}/promtool"                    "/bin/promtool"

RUN mkdir -pv "/etc/prometheus"
RUN mv -vif "${SRC}/prometheus.yml"              "/etc/prometheus/prometheus.yml"

RUN mkdir -pv "/usr/share/prometheus"
RUN mv -vif "${SRC}/console_libraries/"          "/usr/share/prometheus/"
RUN mv -vif "${SRC}/consoles/"                   "/usr/share/prometheus/"

#COPY npm_licenses.tar.bz2                        /npm_licenses.tar.bz2

RUN ln -s /usr/share/prometheus/console_libraries /usr/share/prometheus/consoles/ /etc/prometheus/
RUN mkdir -p /prometheus && \
    chown -R nobody:nobody etc/prometheus /prometheus

# Cleanup
RUN rm -rvf "${SRC}" package.tar.gz

USER       nobody
EXPOSE     9090
VOLUME     [ "/prometheus" ]
WORKDIR    /prometheus
ENTRYPOINT [ "/bin/prometheus" ]
CMD        [ "--config.file=/etc/prometheus/prometheus.yml", \
             "--storage.tsdb.path=/prometheus", \
             "--web.console.libraries=/usr/share/prometheus/console_libraries", \
             "--web.console.templates=/usr/share/prometheus/consoles" ]
