#!/bin/bash

# Ensure compatibility with macOS
if ! command -v gseq &> /dev/null; then
    if command -v seq &> /dev/null; then
        alias gseq='seq'
    else
        echo "Error: 'seq' command not found. Please install coreutils."
        exit 1
    fi
fi

# List of container images to use
containers=(
    "nginx:latest"
    "alpine:latest"
    "busybox:latest"
    "ubuntu:latest"
    "php:7.4-apache"
    "tomcat:9.0"
    "wordpress:latest"
    "node:18"
    "mysql:8.0"
    "redis:7.0"
    "centos:7"
    "httpd:2.4"
    "mongo:4.4"
    "debian:10"
    "golang:1.16"
    "python:3.9"
    "ruby:2.7"
    "perl:5.32"
    "openjdk:11"
    "cassandra:3.11"
    "elasticsearch:7.10"
    "logstash:7.10"
    "kibana:7.10"
    "haproxy:2.2"
    "vault:1.6"
    "consul:1.9"
    "etcd:3.4"
    "zookeeper:3.6"
    "rabbitmq:3.8"
    "memcached:1.6"
    "grafana:7.3"
    "prometheus:2.24"
    "traefik:v2.4"
    "fluentd:v1.11"
    "influxdb:1.8"
    "gitlab/gitlab-ce:14.0.0"
    "jenkins/jenkins:lts"
    "sonarqube:8.6"
    "eclipse-mosquitto:2.0"
    "nextcloud:20"
    "owncloud:10.6"
    "joomla:3.9"
    "drupal:9.1"
    "nginx:1.14"
    "postgres:12"
    "phpmyadmin:5.1"
    "ghost:3.42"
    "openvpn:2.4"
    "mediawiki:1.35"
    "rocketchat/rocket.chat:3.9"
    "vulnerables/web-dvwa"
    "vulnerables/metasploitable"
    "vulhub/phpmyadmin:4.8"
    "vulhub/tomcat:7"
    "vulhub/jenkins:2.150"
    "vulhub/elasticsearch:1.4"
    "vulhub/drupal:7"
    "vulhub/wordpress:4.7"
    "vulhub/gitlab:11.4"
    "vulhub/memcached:1.4"
    "vulhub/redis:2.8"
    "vulhub/mongo-express:0.49"
    "vulhub/php:5.6"
    "vulhub/mysql:5.5"
    "vulhub/couchdb:1.6"
    "vulhub/rabbitmq:3.6"
    "vulhub/zookeeper:3.4"
    "vulhub/logstash:5.5"
    "vulhub/haproxy:1.5"
    "vulhub/grafana:2.6"
    "vulhub/influxdb:0.13"
    "vulhub/fluentd:0.12"
    "vulhub/traefik:v1.7"
    "vulhub/sonarqube:5.6"
    "vulhub/openvpn:2.3"
    "vulhub/ghost:1.23"
    "vulhub/joomla:3.5"
    "vulhub/owncloud:8.1"
    "vulhub/nextcloud:12"
    "vulhub/drupal:6"
    "vulhub/nginx:1.10"
    "vulhub/postgres:9.6"
    "vulhub/phpmyadmin:4.6"
    "vulhub/elasticsearch:1.0"
    "vulhub/tomcat:6"
)

container_names=()
for img in "${containers[@]}"; do
    container_names+=("$(echo "$img" | tr ':/' '-')")
done

# Default values
NAMESPACE="default"
NUM_REPLICAS=1
ACTION="create"

# Parse command-line options
while getopts "d:n:r:" opt; do
    case ${opt} in
        d) ACTION="delete" ;;
        n) NAMESPACE=$OPTARG ;;
        r) NUM_REPLICAS=$OPTARG ;;
        *) echo "Usage: $0 [-d] [-n namespace] [-r num_replicas]"; exit 1 ;;
    esac
done

# Function to create deployments
create_deployments() {
    for i in "${!containers[@]}"; do
        deployment_name="${container_names[$i]}-deployment"
        cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $deployment_name
  namespace: $NAMESPACE
spec:
  replicas: $NUM_REPLICAS
  selector:
    matchLabels:
      app: $deployment_name
  template:
    metadata:
      labels:
        app: $deployment_name
    spec:
      containers:
      - name: ${container_names[$i]}-container
        image: ${containers[$i]}
        ports:
        - containerPort: 80
EOF
        echo "Deployment $deployment_name created with image ${containers[$i]}"
    done
}

# Function to delete deployments
delete_deployments() {
    for i in "${!containers[@]}"; do
        deployment_name="${container_names[$i]}-deployment"
        kubectl delete deployment $deployment_name -n $NAMESPACE --ignore-not-found
        echo "Deployment $deployment_name deleted"
    done
}

# Execute the chosen action
if [ "$ACTION" == "delete" ]; then
    delete_deployments
else
    create_deployments
fi

