#!/bin/bash
while getopts ":i:s:" opt; do
  case "${opt}" in
    i)
      IMAGE="${OPTARG}"
      echo $IMAGE;;
    s)
      SERVICE_NAME="${OPTARG}"
      echo $SERVICE_NAME;;
    *)
      echo "ERROR": Invalid option >&2;;
  esac
done
shift $((OPTIND-1))

cat > marathon.json <<EOF
{
  "id": "/nginx-version-test",
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "docker.fractalindustries.com/nginx-version-test:${IMAGE}",
      "network": "BRIDGE",
      "portMappings": [
        { 
          "hostPort": 0, 
          "containerPort": 80, 
          "servicePort": 0, 
          "protocol": "tcp",
          "labels": {
            "VIP_0": "/nginx-version-test:80"
          },
          "name":"nginx-l4lb"
        }
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
  "upgradeStrategy": {
    "minimumHealthCapacity": 1,
    "maximumOverCapacity": 1
  },
  "unreachableStrategy": {
    "inactiveAfterSeconds": 300,
    "expungeAfterSeconds": 600
  },
  "acceptedResourceRoles": ["slave_public"],
  "labels": {
    "Marathon_Name":"nginx-version-test-marathon-label",
    "HAPROXY_GROUP":"external",
    "HAPROXY_0_VHOST":"nginx-version-test.fos"
  }
}

EOF
cat marathon.json
