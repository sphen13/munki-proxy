FROM nginx:stable

ENV MUNKI_ROOT ""
ENV UPSTREAM_SERVER ""

COPY run /usr/local/bin/run

RUN chmod +x /usr/local/bin/run

VOLUME ["/cache"]

CMD ["/usr/local/bin/run"]