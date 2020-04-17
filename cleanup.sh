#!/usr/bin/env bash
shopt -s expand_aliases
alias aws='docker run --rm -t $(tty &>/dev/null && echo "-i") -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" -v "$(pwd):/project" mesosphere/aws-cli'

## delete the cloudformation stack
aws cloudformation delete-stack --stack-name test-stack

## remove rke files
rm cluster.rkestate || true
rm cluster.yml || true
rm kube_config_cluster.yml || true
