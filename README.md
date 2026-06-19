# Jenkins SSH Agent Setup

A reusable Docker-based Jenkins SSH Agent setup for running CI/CD pipelines with support for Git, Java, Maven, Docker, and Python.

## Features

* SSH-based Jenkins agents
* OpenJDK 21
* Git and Maven pre-installed
* Docker support via mounted Docker socket
* Python 3 and pip
* Multi-agent setup support
* Portable across different machines
* Persistent agents using Docker restart policies

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

## Quick Start

### Create Docker Network

```bash
docker network create jenkins-agents
```

### Start All Agents

Make the script executable:

```bash
chmod +x start-agents.sh
```

Run:

```bash
./start-agents.sh
```

This will automatically start:

| Agent  | Port |
| ------ | ---- |
| agent1 | 2201 |
| agent2 | 2202 |
| agent3 | 2203 |

### Manual Agent Creation (Optional)

If you prefer creating agents manually:

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

For additional agents, change the container name and SSH port.

---

## Jenkins Configuration

> Starting the containers alone is not enough. Each container must be registered as a Jenkins node before it can execute pipelines.

### Step 1: Create SSH Credentials

1. Navigate to **Manage Jenkins → Credentials**
2. Select **Global credentials (unrestricted)**
3. Click **Add Credentials**
4. Configure:

   * Kind: **SSH Username with private key**
   * Username: `jenkins`
   * Private Key: Enter your private SSH key
   * ID: `jenkins-agent-ssh`
5. Save

### Step 2: Create a New Node

1. Navigate to **Manage Jenkins → Nodes**
2. Click **New Node**
3. Enter:

   * Node Name: `agent1`
   * Type: **Permanent Agent**
4. Click **Create**

### Step 3: Configure the Node

Use the following settings:

| Setting                        | Value                               |
| ------------------------------ | ----------------------------------- |
| Number of Executors            | 2                                   |
| Remote Root Directory          | `/home/jenkins`                     |
| Labels                         | `agent1`                            |
| Usage                          | Use this node as much as possible   |
| Launch Method                  | Launch agents via SSH               |
| Host                           | `<Docker Host IP>`                  |
| Port                           | `2201`                              |
| Credentials                    | `jenkins-agent-ssh`                 |
| Host Key Verification Strategy | Non verifying Verification Strategy |

Save the configuration.

### Step 4: Configure Additional Nodes

Repeat the same process for the remaining agents:

| Node Name | Label  | Port |
| --------- | ------ | ---- |
| agent1    | agent1 | 2201 |
| agent2    | agent2 | 2202 |
| agent3    | agent3 | 2203 |

### Step 5: Verify Agent Status

Navigate to:

```text
Manage Jenkins → Nodes
```

Expected:

```text
agent1  Online
agent2  Online
agent3  Online
```

---

## Verify Agent

Create a Pipeline Job and run:

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

Expected output:

* User: `jenkins`
* Git version
* Java version
* Docker version
* Running containers

---

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
* zip

---

## Security Notes

Never commit:

* Private SSH keys
* AWS credentials
* GitHub Personal Access Tokens
* Docker Hub passwords
* `.env` files containing secrets

Only the public key (`id_ed25519.pub`) should be included in the repository.

## Architecture

```text
Jenkins Controller
        │
        ├── SSH → agent1 (Port 2201)
        ├── SSH → agent2 (Port 2202)
        └── SSH → agent3 (Port 2203)

Agents
    │
    └── Docker Socket
            │
            ▼
      Host Docker Engine
```

The Jenkins controller connects to each agent over SSH. Docker commands executed inside the agents are forwarded to the host Docker Engine through the mounted Docker socket.

---

## Using Agent Labels

Agents can be targeted individually using Jenkins labels.

Example:

```groovy
pipeline {
    agent { label 'agent2' }

    stages {
        stage('Build') {
            steps {
                sh 'hostname'
            }
        }
    }
}
```

Available labels:

* `agent1`
* `agent2`
* `agent3`

This allows workloads to be distributed across multiple Jenkins agents.

---

---

## Author

**Shamel Khan**

GitHub: https://github.com/shamelsk
