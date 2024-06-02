#!/bin/bash

# Start the Docker daemon as root with necessary capabilities
sudo dockerd &

# Wait for Docker to start
while ! sudo docker info >/dev/null 2>&1; do
    sleep 1
done

# Ensure the jenkins user has necessary Docker permissions
sudo usermod -aG docker jenkins
sudo chmod 666 /var/run/docker.sock

# Run the original entrypoint as jenkins user
exec /usr/local/bin/jenkins-agent "$@"
