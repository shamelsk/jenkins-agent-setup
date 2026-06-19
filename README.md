# Jenkins SSH Agent Setup

A reusable Docker-based Jenkins SSH Agent setup for CI/CD pipelines with support for Git, Java, Maven, Docker, and Python.

## Features

* SSH-based Jenkins agents
* OpenJDK 21
* Git and Maven pre-installed
* Docker support via mounted Docker socket
* Python 3 and pip
* Portable across different machines
* Multi-agent setup support
* Automatic restart using Docker restart policies

## Project Structure

```text
.
├── Dockerfile
├── docker-entrypoint.sh
├── start-agents.sh
├── .gitignore
└── ssh/
    └── id_ed25519.pub
```

## Prerequisites

* Docker installed on the host machine
* Jenkins Controller running
* SSH key pair generated
* Docker network for Jenkins agents

## Build Image

```bash
docker build -t shamel1012/jenkins-agent:latest .
```

## Push Image to Docker Hub

```bash
docker login
docker push shamel1012/jenkins-agent:latest
```

## Create Docker Network

```bash
docker network create jenkins-agents
```

## Start Agents

A helper script is included to start all Jenkins agents automatically.

Make the script executable:

```bash
chmod +x start-agents.sh
```

Run:

```bash
./start-agents.sh
```

This will start:

* agent1 (Port 2201)
* agent2 (Port 2202)
* agent3 (Port 2203)

## Manual Agent Creation

If you prefer to create agents manually:

```bash
docker run -d \
  --name agent1 \
  --network jenkins-agents \
  -p 2201:22 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --group-add $(stat -c '%g' /var/run/docker.sock) \
  --restart unless-stopped \
  shamel1012/jenkins-agent:latest
```

Repeat for additional agents by changing the container name and SSH port.

## Jenkins Node Configuration

Configure each node in Jenkins:

| Setting               | Value                   |
| --------------------- | ----------------------- |
| Launch Method         | Launch agents via SSH   |
| Remote Root Directory | `/home/jenkins`         |
| Host                  | Docker host IP          |
| Credentials           | Jenkins SSH Credentials |

Example:

| Agent  | Port | Label  |
| ------ | ---- | ------ |
| agent1 | 2201 | agent1 |
| agent2 | 2202 | agent2 |
| agent3 | 2203 | agent3 |

## Verify Agent

Example Jenkins Pipeline:

```groovy
pipeline {
    agent { label 'agent1' }

    stages {
        stage('Verify Agent') {
            steps {
                sh 'whoami'
                sh 'git --version'
                sh 'java -version'
                sh 'docker --version'
                sh 'docker ps'
            }
        }
    }
}
```

## Installed Tools

* OpenJDK 21
* Git
* Maven
* Docker
* Python 3
* pip
* curl
* wget
* unzip

## Security Notes

Never commit:

* Private SSH keys
* AWS credentials
* GitHub Personal Access Tokens
* Docker Hub passwords
* `.env` files containing secrets

Only the public key (`id_ed25519.pub`) should be included in the repository.

## Author

**Shamel Khan**

GitHub: https://github.com/shamelsk
