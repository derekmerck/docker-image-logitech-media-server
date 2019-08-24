FROM ubuntu:latest
MAINTAINER Lars Kellogg-Stedman <lars@oddbit.com>

# Nightly
ARG PACKAGE_VERSION_URL=http://downloads.slimdevices.com/nightly/7.9/sc/25f77d7bd57a9ea70a4cf4a6b5be974849fd2a05/logitechmediaserver_7.9.2~1565967976_amd64.deb

ENV SQUEEZE_VOL /srv/squeezebox
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
	apt-get -y --no-install-recommends install \
		curl \
		wget \
		faad \
		flac \
		lame \
		sox \
		libio-socket-ssl-perl \
		tzdata \
		wavpack \
		libgomp1 \
		ca-certificates \
		&& \
	apt-get clean

RUN curl -Lsf -o /tmp/logitechmediaserver.deb "$PACKAGE_VERSION_URL" && \
	dpkg -i /tmp/logitechmediaserver.deb && \
	rm -f /tmp/logitechmediaserver.deb && \
	apt-get clean

RUN for ASDF in 5.12 5.14 5.16 5.18 5.20 5.22 5.26; do rm -r /usr/share/squeezeboxserver/CPAN/arch/$ASDF; done

# This will be created by the entrypoint script.
RUN userdel squeezeboxserver

VOLUME $SQUEEZE_VOL
EXPOSE 3483 3483/udp 9000 9090 1900/udp

COPY entrypoint.sh /entrypoint.sh
COPY start-squeezebox.sh /start-squeezebox.sh
RUN chmod 755 /entrypoint.sh /start-squeezebox.sh
ENTRYPOINT ["/entrypoint.sh"]
