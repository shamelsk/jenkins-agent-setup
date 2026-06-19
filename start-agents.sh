#!/bin/bash

docker run -d \
  --name agent1 \
  --network jenkins-agents \
  -p 2201:22 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --group-add $(stat -c '%g' /var/run/docker.sock) \
  --restart unless-stopped \
  shamel1012/jenkins-agent:latest

docker run -d \
  --name agent2 \
  --network jenkins-agents \
  -p 2202:22 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --group-add $(stat -c '%g' /var/run/docker.sock) \
  --restart unless-stopped \
  shamel1012/jenkins-agent:latest

docker run -d \
  --name agent3 \
  --network jenkins-agents \
  -p 2203:22 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --group-add $(stat -c '%g' /var/run/docker.sock) \
  --restart unless-stopped \
  shamel1012/jenkins-agent:latest
