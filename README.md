# bootstrap-poc

This repository provides a proof of concept for initializing a CrateKube kubernetes cluster using AWS Cloudformation.

## How does this work

The [cloudformation template](cloudformation/base-cluster.yaml) contains all the AWS resources needed to start a base
Kubernetes cluster.  To create the resource an aws cloudformation cli call can be made, an example is below:

```shell script
aws cloudformation deploy --template-file cloudformation/base-cluster.yaml --stack-name test-stack --parameter-overrides "Keyname=<name of keypair>" "IamUser=<IAM user>" --capabilities "CAPABILITY_NAMED_IAM"
```

Once the EC2 instances are available the kubernetes cluster launch the bootstrap container using the docker run command below.
The bootstrap container will gather all the provisioned EC2 instances and start building the kubernetes cluster using `rke`.

```shell script
docker run -d -v cratekube-bootstrap:/cratekube/bootstrap -e AWS_ACCESS_KEY_ID=<API key> -e AWS_SECRET_ACCESS_KEY=<API secret> kod4n/cratekube-bootstrap:latest test-stack
```
