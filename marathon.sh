#!/bin/bash

for i in "$@"
do
case $i in
    -i=*|--image=*)
    IMAGE="${i#*=}"
    ;;
    -s=*|--service_name=*)
    SERVICE_NAME="${i#*=}"
    ;;
    -r=*|--docker_registry=*)
    DOCKER_REGISTRY="${i#*=}"
    ;;
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
