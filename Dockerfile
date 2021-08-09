FROM 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_base:latest

#
# Basic Parameters
#
ARG ARCH="amd64"
ARG OS="linux"
ARG VER="2.28.1"
ARG PKG="prometheus"
ARG SRC="${PKG}-${VER}.${OS}-${ARCH}"
ARG UID="prometheus"

#
# Some important labels
#
LABEL ORG="Armedia LLC"
LABEL MAINTAINER="Devops Team <devops@armedia.com>"
LABEL APP="Prometheus"
LABEL VERSION="${VER}"
LABEL IMAGE_SOURCE="https://github.com/ArkCase/ark_prometheus"

#
# Create the required user
#
RUN useradd --system --user-group "${UID}"

#
# Download the primary artifact
#
RUN curl \
        -L "https://github.com/prometheus/${PKG}/releases/download/v${VER}/${SRC}.tar.gz" \
        -o - | tar -xzvf -

#
# Create the necessary directories
#
RUN mkdir -pv "/app/data" "/app/conf" "/usr/share/prometheus"

#
# Deploy the extracted files
#
RUN mv -vif "${SRC}/LICENSE"            "/LICENSE"
RUN mv -vif "${SRC}/NOTICE"             "/NOTICE"
RUN mv -vif "${SRC}/prometheus"         "/usr/bin/prometheus"
RUN mv -vif "${SRC}/promtool"           "/usr/bin/promtool"
RUN mv -vif "${SRC}/prometheus.yml"     "/app/conf/prometheus.yml"
RUN mv -vif "${SRC}/console_libraries/" "/usr/share/prometheus/"
RUN mv -vif "${SRC}/consoles/"          "/usr/share/prometheus/"

#
# Create any missing links
#
RUN ln -sv "/usr/share/prometheus/console_libraries" "/app/conf"
RUN ln -sv "/usr/share/prometheus/consoles"          "/app/conf"
RUN ln -sv "/app/conf"                               "/etc/prometheus"

#
# Set ownership + permissions
#
RUN chown -R "${UID}:"    "/app/data" "/app/conf"
RUN chmod -R ug+rwX,o-rwx "/app/data" "/app/conf"

#
# Cleanup
#
RUN rm -rvf "${SRC}"

#
# Final parameters
#
USER        ${UID}
EXPOSE      9090
VOLUME      [ "/app/data", "/app/conf" ]
WORKDIR     /app/data
ENTRYPOINT  [ "/usr/bin/prometheus" ]
CMD         [ "--config.file=/app/conf/prometheus.yml", \
              "--storage.tsdb.path=/app/data", \
              "--web.console.libraries=/usr/share/prometheus/console_libraries", \
              "--web.console.templates=/usr/share/prometheus/consoles" ]
