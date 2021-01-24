#!/bin/bash

su postgres -c "/usr/lib/postgresql/12/bin/initdb"
sed -i 's/127.0.0.1\/32 .*/0.0.0.0\/0 md5/' /etc/postgresql/12/main/pg_hba.conf
sed -i 's/^#port = 5432.*/port = 5432/' /etc/postgresql/12/main/postgresql.conf
sed -i "s/^#listen_addresses .*/listen_addresses='*'/" /etc/postgresql/12/main/postgresql.conf

su postgres -c "pg_ctlcluster 12 main start"

curl -L "https://github.com/wal-g/wal-g/releases/download/v0.2.15/wal-g.linux-amd64.tar.gz" -o "wal-g.linux-amd64.tar.gz"
tar -xzf wal-g.linux-amd64.tar.gz
mv wal-g /usr/local/bin/

####
cat > /var/lib/postgresql/.walg.json << EOF
{
    "WALG_S3_PREFIX": "s3://your_bucket/path",
    "AWS_ACCESS_KEY_ID": "key_id",
    "AWS_SECRET_ACCESS_KEY": "secret_key",
    "WALG_COMPRESSION_METHOD": "brotli",
    "WALG_DELTA_MAX_STEPS": "5",
    "PGDATA": "/var/lib/postgresql/12/main",
    "PGHOST": "/var/run/postgresql/.s.PGSQL.5432"
}
EOF

chown postgres: /var/lib/postgresql/.walg.json
#####
echo "wal_level=replica" >> /etc/postgresql/12/main/postgresql.conf
echo "archive_mode=on" >> /etc/postgresql/12/main/postgresql.conf
echo "archive_command='/usr/local/bin/wal-g wal-push \"%p\" >> /var/log/postgresql/archive_command.log 2>&1' " >> /etc/postgresql/12/main/postgresql.conf
echo "archive_timeout=300" >> /etc/postgresql/12/main/postgresql.conf
echo "restore_command='/usr/local/bin/wal-g wal-fetch \"%f\" \"%p\" >> /var/log/postgresql/restore_command.log 2>&1' " >> /etc/postgresql/12/main/postgresql.conf
#####
su  postgres -c "psql -c \"alter user postgres with password 'password'\""
su  postgres -c "/usr/local/bin/wal-g backup-push /var/lib/postgresql/12/main"
#####

echo "*/5 * * * *    /usr/local/bin/wal-g backup-push /var/lib/postgresql/12/main >> /var/log/postgresql/walg_backup.log 2>&1" >> /var/spool/cron/crontabs/postgres
chown postgres: /var/spool/cron/crontabs/postgres
chmod 600 /var/spool/cron/crontabs/postgres
