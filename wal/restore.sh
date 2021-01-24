docker exec pg service postgresql stop
docker exec pg rm -c "-rf /var/lib/postgresql/12/main/*"
docker exec pg su  postgres '/usr/local/bin/wal-g backup-fetch /var/lib/postgresql/12/main '
docker cp recovery.conf pg:/var/lib/postgresql/12/main
docker cp recovery.signal pg:/var/lib/postgresql/12/main
docker exec pg service postgresql start