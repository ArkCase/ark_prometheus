ARG ARCH="amd64"
ARG OS="linux"
FROM 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_base:latest
LABEL maintainer="Armedia, LLC"

ARG ARCH="amd64"
ARG OS="linux"
ARG VER="2.28.1"
ARG PKG="prometheus"
ARG SRC="${PKG}-${VER}.${OS}-${ARCH}"

RUN curl \
		-L "https://github.com/prometheus/${PKG}/releases/download/v${VER}/${SRC}.tar.gz" \
		-o package.tar.gz && \
	tar -xzvf "package.tar.gz" && \
	mkdir -pv "/prometheus" && \
	mkdir -pv "/etc/prometheus" && \
	mkdir -pv "/usr/share/prometheus" && \
	mv -vif "${SRC}/LICENSE"                     "/LICENSE" && \
	mv -vif "${SRC}/NOTICE"                      "/NOTICE" && \
	mv -vif "${SRC}/prometheus"                  "/bin/prometheus" && \
	mv -vif "${SRC}/promtool"                    "/bin/promtool" && \
	mv -vif "${SRC}/prometheus.yml"              "/etc/prometheus/prometheus.yml" && \
	mv -vif "${SRC}/console_libraries/"          "/usr/share/prometheus/" && \
	mv -vif "${SRC}/consoles/"                   "/usr/share/prometheus/" && \
	ln -s "/usr/share/prometheus/console_libraries" "/etc/prometheus" && \
	ln -s "/usr/share/prometheus/consoles"          "/etc/prometheus" && \
	chown -R nobody:nobody "/etc/prometheus" "/prometheus" && \
	rm -rvf "${SRC}" package.tar.gz

#COPY npm_licenses.tar.bz2                        /npm_licenses.tar.bz2

USER       nobody
EXPOSE     9090
VOLUME     [ "/prometheus" ]
WORKDIR    /prometheus
ENTRYPOINT [ "/bin/prometheus" ]
CMD        [ "--config.file=/etc/prometheus/prometheus.yml", \
             "--storage.tsdb.path=/prometheus", \
             "--web.console.libraries=/usr/share/prometheus/console_libraries", \
             "--web.console.templates=/usr/share/prometheus/consoles" ]
