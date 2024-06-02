# Jenkins Inbound Agent Setup

This guide describes how to set up a Jenkins inbound agent with the required packages and artifacts. The agent is designed to run in privileged mode to support Docker-in-Docker (DIND) functionality.

## Prerequisites

- Jenkins master server
- Docker installed on the host machine

## Packages Included

- `jq`
- `curl`
- `unzip`
- `sudo`
- `gnupg`
- `lsb-release`
- `apt-transport-https`
- `ca-certificates`
- `software-properties-common`

## Artifacts Included

- HashiCorp Vault
- Docker-in-Docker (DIND)
- 1Password CLI
- `kubectl`
- AWS CLI



## Entry Point Script
The entrypoint.sh script ensures that the Docker daemon starts correctly and the jenkins user has the necessary permissions to use Docker.

## Build the Docker Image
Build the Docker image using the provided Dockerfile.

```docker build -t jenkins-inbound-agent .```


## Run the Docker Container
Run the Docker container in privileged mode to enable DIND.
```docker run -d --name jenkins-agent --privileged \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e JENKINS_URL=<your-jenkins-url> \
    -e JENKINS_AGENT_NAME=<your-agent-name> \
    -e JENKINS_SECRET=<your-agent-secret> \
    jenkins-inbound-agent
```

Replace <your-jenkins-url>, <your-agent-name>, and <your-agent-secret> with your Jenkins master URL, the agent name, and the agent secret respectively.

## Notes
Running the container in **privileged** mode is necessary for Docker-in-Docker functionality.
Ensure that Docker and Jenkins are properly configured on your host machine to avoid permission issues.

