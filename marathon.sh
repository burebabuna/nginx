#!/bin/bash
cat > marathon.json <<EOF
{
  "id": "/${1}",
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "fractal-docker-fos-prod.bintray.io/${1}:${2}",
      "network": "BRIDGE",
      "portMappings": [
        { "hostPort": 0, "containerPort": 80, "servicePort": 0, "protocol": "tcp"}
      ]
    }
  },
  "instances":1,
  "cpus": 0.1,
  "mem": 64,
  "uris": [
    "file:///mnt/jenkins/docker.tar.gz"
  ],
  "labels": {
    "HAPROXY_GROUP":"external",
    "HAPROXY_0_VHOST":"${1}.fos"
  }
}
EOF
cat marathon.json