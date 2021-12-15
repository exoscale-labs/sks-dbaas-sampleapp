#!/bin/bash

export KUBECONFIG=kubeconfig

connectionurl=$(terraform output -raw database_uri)
#connectionurl="mysql://username:password@dburl.aivencloud.com:21699/defaultdb?ssl-mode=REQUIRED"

user=$(echo $connectionurl | tr "/@:?" "\n" | sed -n '4p')
password=$(echo $connectionurl | tr "/@:?" "\n" | sed -n '5p')
host=$(echo $connectionurl | tr "/@:?" "\n" | sed -n '6p')
port=$(echo $connectionurl | tr "/@:?" "\n" | sed -n '7p')
db=$(echo $connectionurl | tr "/@:?" "\n" | sed -n '8p')

helm repo add bitnami https://charts.bitnami.com/bitnami
#helm repo update

helm install \
    --set mariadb.enabled=false \
    --set externalDatabase.host=$host \
    --set externalDatabase.user=$user \
    --set externalDatabase.password=$password \
    --set externalDatabase.database=$db \
    --set externalDatabase.port=$port \
    --set persistence.storageClass=longhorn \
    --set wordpressUsername=admin \
    --set wordpressPassword=vXUdxiWA4c \
    blog bitnami/wordpress