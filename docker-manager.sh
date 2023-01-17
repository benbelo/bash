#!/bin/bash

# Function to display the usage of the script
usage() {
    echo "Usage: $0 [start|stop|restart|status|logs] [compose|docker] [path/to/docker-compose.yml]"
    exit 1
}

# Check if the command, usage and path are passed as arguments
if [ $# -ne 3 ]; then
    usage
fi

# Store the command, usage and path in variables
cmd=$1
use=$2
path=$3

# Check the usage and run the corresponding command
if [ "$use" == "compose" ]; then
    # Use docker-compose
    if [ "$cmd" == "start" ]; then
        # Start the containers using docker-compose
        docker-compose -f $path up -d
    elif [ "$cmd" == "stop" ]; then
        # Stop the containers using docker-compose
        docker-compose -f $path down
    elif [ "$cmd" == "restart" ]; then
        # Restart the containers using docker-compose
        docker-compose -f $path down
        docker-compose -f $path up -d
    elif [ "$cmd" == "status" ]; then
        # Print the status of the containers
        docker-compose -f $path ps
    elif [ "$cmd" == "logs" ]; then
        # Print the logs of the containers
        docker-compose -f $path logs -f
    else
        usage
    fi
elif [ "$use" == "docker" ]; then
    # Use docker
    if [ "$cmd" == "start" ]; then
        # Start the containers using docker
        for container in $(docker ps -q --filter "status=exited")
        do
        docker start "$container"
        done
    elif [ "$cmd" == "stop" ]; then
        # Stop the containers using docker
        for container in $(docker ps -q)
        do
        docker stop "$container"
        done
    elif [ "$cmd" == "restart" ]; then
        # Restart the containers using docker
        for container in $(docker ps -q)
        do
        docker restart "$container"
        done
    elif [ "$cmd" == "status" ]; then
        # Print the status of the containers
        docker ps -a
    elif [ "$cmd" == "logs" ]; then
        # Print the logs of the containers
        for container in $(docker ps -q)
        do
        echo "$container logs:"
        echo "-------------------------------"
        docker logs "$container"
        echo ""
        done
    else
        usage
    fi
else
    usage
fi

