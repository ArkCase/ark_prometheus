ARG ARCH="amd64"
ARG OS="linux"
ARG VER="2.28.1"
ARG PKG="prometheus"
ARG SRC="${PKG}-${VER}.${OS}-${ARCH}"

FROM 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_base:latest

LABEL	ORG="Armedia LLC" \
		APP="Prometheus" \
		VERSION="${VER}" \
		IMAGE_SOURCE="https://github.com/ArkCase/ark_prometheus" \
		MAINTAINER="Armedia LLC"

# Modify to fetch from S3 ...
RUN curl \
		-L "https://github.com/prometheus/${PKG}/releases/download/v${VER}/${SRC}.tar.gz" \
		-o "package.tar.gz" && \
	tar -xzvf "package.tar.gz" && \
	mkdir -pv "/app/data" && \
	mkdir -pv "/app/conf" && \
	mkdir -pv "/usr/share/prometheus" && \
	ln -sv "/app/conf" "/etc/prometheus" && \
	mv -vif "${SRC}/LICENSE"						"/LICENSE" && \
	mv -vif "${SRC}/NOTICE"							"/NOTICE" && \
	mv -vif "${SRC}/prometheus"						"/bin/prometheus" && \
	mv -vif "${SRC}/promtool"						"/bin/promtool" && \
	mv -vif "${SRC}/prometheus.yml"					"/app/conf/prometheus.yml" && \
	mv -vif "${SRC}/console_libraries/"				"/usr/share/prometheus/" && \
	mv -vif "${SRC}/consoles/"						"/usr/share/prometheus/" && \
	ln -s "/usr/share/prometheus/console_libraries"	"/app/conf" && \
	ln -s "/usr/share/prometheus/consoles"			"/app/conf" && \
	chown -R nobody:nobody	"/app/data" "/app/conf" && \
	chmod -R ug+rwX,o-rwx	"/app/data" "/app/conf" && \
	rm -rvf "${SRC}" "package.tar.gz"

#COPY npm_licenses.tar.bz2	/npm_licenses.tar.bz2

USER		nobody
EXPOSE		9090
VOLUME		[ "/app/data", "/app/conf" ]
WORKDIR		/app/data
ENTRYPOINT	[ "/bin/prometheus" ]
CMD			[ "--config.file=/app/conf/prometheus.yml", \
			  "--storage.tsdb.path=/app/data", \
			  "--web.console.libraries=/usr/share/prometheus/console_libraries", \
			  "--web.console.templates=/usr/share/prometheus/consoles" ]
