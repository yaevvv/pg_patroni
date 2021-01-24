#!/bin/bash

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
# обязательно меняем владельца файла:
chown postgres: /var/lib/postgresql/.walg.json