#!/bin/bash
for i in "$@"
do
case $i in 
    -i=*|--tag=*)
  TAG="${i#*=}"
  ;;
    *)
  ;;
esac
done
cat > marathon.json <<EOF
{
  "id": "nginx-version-test",
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "fractal-docker-registry.bintray.io/nginx-version-test:${TAG}",
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
    "HAPROXY_0_VHOST":"nginx-version-test.fos"
  }
}
EOF