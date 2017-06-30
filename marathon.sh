#!/bin/bash

while [[ $# -gt 0 ]];
do
  opt ="$1"
  shift;
case "$opt" in
    "-i" ) IMAGE="$1"; shift ;;
    "-s" ) SERVICE_NAME="$1"; shift ;;
    "-r" ) DOCKER_REGISTRY="$1"; shift ;;
    *    ) echo "ERROR": Invalid option: \""$opt"\"" >&2
           exit 1 ;;
esac
done

cat > marathon.json <<EOF
{
  "id": "/${SERVICE_NAME}",
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "${DOCKER_REGISTRY}/${SERVICE_NAME}:${IMAGE}",
      "network": "BRIDGE",
      "portMappings": [
        { "hostPort": 0, "containerPort": 80, "servicePort": 0, "protocol": "tcp"}
      ]
    }
  },
  "instances":1,
  "cpus": 1,
  "mem": 1024,
  "uris": [
    "file:///mnt/jenkins/docker.tar.gz"
  ],
  "healthChecks": [
    {
      "gracePeriodSeconds": 120,
      "intervalSeconds": 30,
      "maxConsecutiveFailures": 3,
      "path": "/",
      "portIndex": 0,
      "protocol": "HTTP",
      "timeoutSeconds": 5
    }
  ],
  "labels": {
    "HAPROXY_GROUP":"external",
    "HAPROXY_0_VHOST":"${SERVICE_NAME}.fos"
  }
}

EOF
cat marathon.json
