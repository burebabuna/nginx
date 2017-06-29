#!/bin/bash

while [[ $# -gt 0 ]]; do
    case "$1" in
    -SERVICE_NAME)
        service_name=$1
        ;;
    -COMMIT_ID)
        commit_id=$2
        ;;
    *)
        exit 1
    esac
done
cat > marathon.json <<EOF
{
  "id": "/$service_name",
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "fractal-docker-fos-prod.bintray.io/$service_name:$commit_id",
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
    "HAPROXY_0_VHOST":"$service_name.fos"
  }
}
EOF
echo "This image is tagged as $service_name:$commit_id"