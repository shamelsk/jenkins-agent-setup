#!/bin/bash

SOCKET_GID=$(stat -c '%g' /var/run/docker.sock 2>/dev/null || echo "")

if [ -n "$SOCKET_GID" ]; then
    groupadd -f -g "$SOCKET_GID" dockerhost
    usermod -aG "$SOCKET_GID" jenkins
fi

exec /usr/sbin/sshd -D
