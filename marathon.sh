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
    *)
  ;;
esac
done

cat > marathon.json <<EOF
{
  "id": "/${SERVICE_NAME}",
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "fractal-docker-fos-prod.bintray.io/${SERVICE_NAME}:${IMAGE}",
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
    "HAPROXY_0_VHOST":"${SERVICE_NAME}.fos"
  }
}

EOF