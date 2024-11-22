#!/bin/bash

# Configuration
CONTAINER_NAME="my-mysql-db"
DEFAULT_PORT=3307
MYSQL_ROOT_PASSWORD="yourpassword"
MYSQL_DATABASE="my_database"
IMAGE_NAME="mysql:latest"

# Function to check if a port is in use
is_port_in_use() {
  lsof -i -P -n | grep -q ":$1"
}

# Function to start the MySQL container
start_container() {
  # Find an available port starting from the default
  PORT=$DEFAULT_PORT
  while is_port_in_use $PORT; do
    echo "Port $PORT is in use. Trying the next port..."
    PORT=$((PORT + 1))
  done

  # Check if the container already exists
  if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Container '${CONTAINER_NAME}' already exists. Restarting it..."
    docker start $CONTAINER_NAME
    echo "MySQL container '${CONTAINER_NAME}' is now running on its previous port."
  else
    # Run a new MySQL container
    echo "Starting MySQL container '${CONTAINER_NAME}' on port ${PORT}..."
    docker run --name $CONTAINER_NAME \
      -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
      -e MYSQL_DATABASE=$MYSQL_DATABASE \
      -p ${PORT}:3306 \
      -d $IMAGE_NAME

    echo "MySQL container '${CONTAINER_NAME}' is now running."
    echo "Host Port: ${PORT}"
    echo "Root Password: ${MYSQL_ROOT_PASSWORD}"
    echo "Database Name: ${MYSQL_DATABASE}"
  fi
}

# Function to stop and remove the MySQL container
stop_container() {
  if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Stopping and removing MySQL container '${CONTAINER_NAME}'..."
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
    echo "MySQL container '${CONTAINER_NAME}' has been stopped and removed."
  else
    echo "No container named '${CONTAINER_NAME}' found."
  fi
}

# Main script logic
case "$1" in
  start)
    start_container
    ;;
  stop)
    stop_container
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    ;;
esac
