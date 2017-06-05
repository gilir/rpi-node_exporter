FROM arm32v6/alpine:3.6

# Upgrating the image first, to have the last version of all packages, and to
# share the same layer accros the images
RUN apk --no-cache upgrade \
    && apk --no-cache add \
       su-exec \
       ca-certificates

ARG NODE_EXPORTER_VERSION=0.14.0 \
    ARCH=armv7

ADD https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-$ARCH.tar.gz /tmp/

RUN cd /tmp && \
    tar -xvf node_exporter-$NODE_EXPORTER_VERSION.linux-$ARCH.tar.gz && \
    cd node_exporter-* && \
    mv node_exporter /bin/node_exporter && \
    cd /tmp && rm -rf node_exporter-$NODE_EXPORTER_VERSION.linux-$ARCH

EXPOSE     9100
ENTRYPOINT [ "/bin/node_exporter" ]
CMD ["-collector.procfs", \
     "/host/proc", \
     "-collector.sysfs", \ 
     "/host/sys", \
     "-collector.filesystem.ignored-mount-points", \
     "^/(sys|proc|dev|host|etc)($|/)", \
     "--collector.textfile.directory", \
     "/etc/node-exporter/", \
     "--collectors.enabled=conntrack,diskstats,entropy,filefd,filesystem,loadavg,mdadm,meminfo,netdev,netstat,stat,textfile,time,vmstat,ipvs"]
