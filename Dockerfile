FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y \
    openssh-server \
    openjdk-21-jre \
    git \
    curl \
    wget \
    unzip \
    zip \
    vim \
    net-tools \
    iputils-ping \
    dnsutils \
    python3 \
    python3-pip \
    docker.io \
    maven && \
    apt clean

RUN useradd -m -s /bin/bash jenkins

RUN mkdir -p /home/jenkins/.ssh
RUN mkdir -p /run/sshd

COPY ssh/id_ed25519.pub /home/jenkins/.ssh/authorized_keys

RUN chown -R jenkins:jenkins /home/jenkins/.ssh && \
    chmod 700 /home/jenkins/.ssh && \
    chmod 600 /home/jenkins/.ssh/authorized_keys

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

CMD ["/usr/local/bin/docker-entrypoint.sh"]
