#!/bin/bash
while getopts ":i:s:r:" opt; do
  case "${opt}" in
    i) 
      IMAGE="${OPTARG}"
      echo $IMAGE;;
    s)
      SERVICE_NAME="${OPTARG}"
      echo $SERVICE_NAME;;
    r)
      DOCKER_REGISTRY="${OPTARG}"
      echo $DOCKER_REGISTRY;;
    *) 
      echo "ERROR": Invalid option >&2;;
  esac
done
shift $((OPTIND-1))

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
