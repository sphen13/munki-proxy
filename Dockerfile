FROM nginx:stable

ENV MUNKI_ROOT ""
ENV UPSTREAM_SERVER ""
ENV PORT 8080
ENV AVAHI_DOMAIN local

RUN apt-get update && \
	apt-get install --no-install-recommends -y avahi-daemon \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY avahi-daemon.conf /etc/avahi/avahi-daemon.conf
COPY run /usr/local/bin/run

RUN chmod +x /usr/local/bin/run

VOLUME ["/cache"]

CMD ["/usr/local/bin/run"]