FROM ubuntu:bionic

ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get install -y mc supervisor vim bash-completion lsb-release wget curl cron procps gnupg gnupg2 gnupg1 && \
    rm -rf /var/lib/apt/lists/* && \
        apt clean
ENV supervisor_conf /etc/supervisor/supervisord.conf
COPY supervisord.conf ${supervisor_conf}
COPY start.sh /start.sh
RUN set -eux; \
	groupadd -r postgres --gid=999; \
	useradd -r -g postgres --uid=999 --home-dir=/var/lib/postgresql --shell=/bin/bash postgres; \
	mkdir -p /var/lib/postgresql; \
	chown -R postgres:postgres /var/lib/postgresql
### PG
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list
RUN apt-get update
RUN apt-get install -y postgresql-12 postgresql-client-12
######
COPY wal.sh /

ENV PGDATA  /var/lib/postgresql/12/main
ENV PATH $PATH:/usr/lib/postgresql/12/bin:/bin:/usr/local/bin

VOLUME ["/var/lib/postresql/12/main"]
EXPOSE 5432

CMD ["/start.sh"]
