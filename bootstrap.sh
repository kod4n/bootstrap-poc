#!/usr/bin/env bash

set -o nounset
set -o errexit

stack_name="$1"

## get output from describe-stacks call
stack_output=$(aws cloudformation describe-stacks --stack-name "${stack_name}")

## get dns values for master and worker nodes
master_id=$(echo "$stack_output" | jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "MasterNodeId") | .OutputValue')
master_az=$(echo "$stack_output" | jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "MasterNodeAZ") | .OutputValue')
master_dns=$(echo "$stack_output" | jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "MasterNodeDNS") | .OutputValue')
worker_id=$(echo "$stack_output" | jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "WorkerNodeId") | .OutputValue')
worker_az=$(echo "$stack_output" | jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "WorkerNodeAZ") | .OutputValue')
worker_dns=$(echo "$stack_output" | jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "WorkerNodeDNS") | .OutputValue')


function ec2InstanceConnect() {
	aws ec2-instance-connect send-ssh-public-key --region us-east-1 --instance-id "${master_id}" --availability-zone "${master_az}" --instance-os-user ec2-user --ssh-public-key file://cratekube_rsa.pub
	aws ec2-instance-connect send-ssh-public-key --region us-east-1 --instance-id "${worker_id}" --availability-zone "${worker_az}" --instance-os-user ec2-user --ssh-public-key file://cratekube_rsa.pub
}

## create ssh key and send public key to nodes
ssh-keygen -q -t rsa -f ./cratekube_rsa -N ''
ec2InstanceConnect

## create cluster yml for rke install
cluster_yml="nodes:
- address: ${master_dns}
  user: ec2-user
  role:
  - controlplane
  - etcd
- address: ${worker_dns}
  user: ec2-user
  role:
  - worker
ssh_key_path: /cratekube/bootstrap/cratekube_rsa
services:
  etcd:
    snapshot: true
    creation: 6h
    retention: 24h
  kube-api:
    pod_security_policy: false
    always_pull_images: true"

echo "master dns $master_dns"
echo "worker dns $worker_dns"
echo ""
echo "using cluster config:"
echo "$cluster_yml"
echo "$cluster_yml" > cluster.yml

echo ""
echo "using rke version: $(rke --version)"

rke up &

iter=0
while [ $iter -le 11 ]
do
	sleep 55
	ec2InstanceConnect
	iter=$(( $iter + 1 ))
done
