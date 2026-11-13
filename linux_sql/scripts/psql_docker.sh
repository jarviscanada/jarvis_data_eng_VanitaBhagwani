
#!/bin/bash

# Capture CLI arguments
cmd=$1
db_username=$2
db_password=$3

# Start Docker if it is not running
sudo systemctl is-active --quiet docker || sudo systemctl start docker

# Check if the container exists
docker container inspect jrvs-psql > /dev/null 2>&1
container_status=$?

case $cmd in
  create)

    # Check if container already exists
    if [ $container_status -eq 0 ]; then
      echo "Container already exists"
      exit 1
    fi

    # Check number of arguments
    if [ $# -ne 3 ]; then
      echo "Create requires username and password"
      exit 1
    fi

    # Create persistent Docker volume
    docker volume create pgdata

    # Create and start PostgreSQL container
    docker run --name jrvs-psql \
      -e POSTGRES_USER=$db_username \
      -e POSTGRES_PASSWORD=$db_password \
      -d -v pgdata:/var/lib/postgresql/data \
      -p 5432:5432 postgres:9.6-alpine

    exit $?
    ;;

  start|stop)

    # Check if container exists
    if [ $container_status -ne 0 ]; then
      echo "Container does not exist"
      exit 1
    fi

    # Start or stop the container
    docker container $cmd jrvs-psql
    exit $?
    ;;

  *)
    echo "Illegal command"
    echo "Commands: start|stop|create"
    exit 1
    ;;
esac
