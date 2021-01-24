docker stop pg && docker rm pg
docker build -t pg:patroni .
docker rm $(docker ps -a | grep  -v pg:patroni | awk '{ print $1 }')
docker rmi -f $(docker images | grep '<none>' | awk '{ print $3 }')
docker run -d \
 --name pg \
 -p 5432:5432 \
 -e POSTGRES_PASSWORD=password \
 -e PGDATA=/var/lib/postgresql/12/main \
 -v /srv/pg/data:/var/lib/postgresql/12/main \
 pg:patroni