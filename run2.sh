#!/bin/bash

#pwd
echo "test deploy " >> README.md
git add .
git commit -m "commit"
git push 

COMMIT_ID=$(git rev-parse --verify HEAD)

docker build -t quay.io/abarbaro/deploy-2:$COMMIT_ID .
docker push quay.io/abarbaro/deploy-2:$COMMIT_ID

oc create ns aaa-test-deploy 

sleep 38

cat <<EOF | kubectl apply -f -
kind: Deployment
apiVersion: apps/v1
metadata:
  name: test-deploy-2
  namespace: aaa-test-deploy
  labels:
    app.kubernetes.io/instance: test-deploy-2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-deploy-2
  template:
    metadata:
      labels:
        app: test-deploy-2
    spec:
      containers:
        - name: container
          image: 'quay.io/abarbaro/deploy-2:$COMMIT_ID'
EOF
